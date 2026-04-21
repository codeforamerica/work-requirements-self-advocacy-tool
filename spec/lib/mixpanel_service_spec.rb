require "rails_helper"

describe MixpanelService do
  context "Testing concurrency" do
    let!(:procs) { [] }  # We maintain a list of procs because the internal the mutex prevents direct invocation
    before do
      ENV["MIXPANEL_TOKEN"] = "123"

      # We are not testing the tracker - so we mock bypass it.
      allow_any_instance_of(Mixpanel::Tracker).to receive(:track).and_wrap_original do |method, distinct_id, event_name, data|
        proc = method.receiver.instance_variable_get(:@sink)
        procs << proc do
          proc.call(distinct_id, event_name, data)
        end
      end

      # Force the singleton to reevaluate
      MixpanelService.remove_instance_variable(:@singleton__instance__)
    end

    it "uses a scheduled task to send buffered events to the server later" do
      expect_any_instance_of(Mixpanel::BufferedConsumer).to receive(:send!).once.with("abcde", "test_event")
      expect_any_instance_of(Mixpanel::BufferedConsumer).to receive(:flush).once

      # We will mock things so that scheduled tasks will execute immediately
      allow_any_instance_of(Concurrent::ScheduledTask).to receive(:execute).and_wrap_original do |method|
        expect(method.receiver.instance_variable_get(:@delay)).to eq 5
        proc = method.receiver.instance_variable_get(:@task)
        procs << proc
      end

      MixpanelService.instance.run(
        distinct_id: "abcde",
        event_name: "test_event",
        data: {test: "OK"}
      )

      while procs.any?
        procs.pop.call
      end
    end

    it "sends events to mixpanel once the buffer is full" do
      # For this test, we reset the buffer size from 50 to 2.
      stub_const "MixpanelService::MAX_BUFFER_SIZE", 2

      expect_any_instance_of(Mixpanel::BufferedConsumer).to receive(:send!).twice.with("abcde", "test_event")
      expect_any_instance_of(Mixpanel::BufferedConsumer).to receive(:flush).once

      # We don't actually want the scheduled task to run at all in this case - but it should be called twice
      # (It is not called that third time when the buffer is full)
      expect(MixpanelService.instance).to receive(:init_flusher).exactly(2).times

      3.times do
        MixpanelService.instance.run(
          distinct_id: "abcde",
          event_name: "test_event",
          data: {test: "OK"}
        )
      end

      while procs.any?
        procs.pop.call
      end
    end
  end

  context "Testing the tracker" do
    let(:fake_consumer) { double("mixpanel buffered consumer") }
    let(:fake_tracker) { double("mixpanel tracker") }

    before do
      allow(fake_consumer).to receive(:send!)
      allow(fake_tracker).to receive(:track)
      MixpanelService.instance.instance_variable_set(:@consumer, fake_consumer)
      MixpanelService.instance.instance_variable_set(:@tracker, fake_tracker)
    end

    after do
      MixpanelService.instance.remove_instance_variable(:@consumer)
      MixpanelService.instance.remove_instance_variable(:@tracker)
    end

    context "when called as a singleton" do
      describe "#instance" do
        it "returns the instance" do
          expect(MixpanelService.instance).to be_a_kind_of(MixpanelService)
          expect(MixpanelService.instance).to equal(MixpanelService.instance)
        end
      end

      describe "#run" do
        let(:sent_params) do
          {
            distinct_id: "abcde",
            event_name: "test_event",
            data: {test: "OK"}
          }
        end
        let(:expected_params) { ["abcde", "test_event", {test: "OK"}] }

        it "calls the internal tracker with expected parameters" do
          MixpanelService.instance.run(**sent_params)
          expect(fake_tracker).to have_received(:track).with(*expected_params)
        end
      end
    end

    context "when called as a service module" do
      let(:distinct_id) { "99991234" }
      let(:event_name) { "test_event" }

      let(:bare_request) { ActionDispatch::Request.new({}) }

      before do
        allow(bare_request).to receive(:referrer).and_return("http://test-host.dev/remove-me/referred")
        allow(bare_request).to receive(:path).and_return("/remove-me/resource")
        allow(bare_request).to receive(:fullpath).and_return("/remove-me/resource?other_field=whatever")
      end

      describe "#send_event" do
        context "asynchronously" do
          let(:stubbed_tracker) {
            Mixpanel::Tracker.new("a_non_functional_mixpanel_key") do |type, message|
              fake_consumer.send!(type, message)
            end
          }

          before do
            MixpanelService.instance.instance_variable_set(:@tracker, stubbed_tracker)
          end

          it "sends them in a separate thread" do
            MixpanelService.send_event(distinct_id: distinct_id, event_name: event_name)
            expect(fake_consumer).to have_received(:send!).with(:event, any_args)
          end
        end

        context "tracking information" do
          it "tracks the event with record, controller, and other information" do
            screener = create(:screener)
            controller_double = instance_double(HomepageController)
            allow(controller_double).to receive(:class).and_return HomepageController
            allow(controller_double).to receive(:action_name).and_return "index"
            allow(controller_double).to receive(:utms_and_referrer).and_return({referrer: "duckduckshrimp.com", utm_source: "duckduckshrimp", utm_medium: nil})

            MixpanelService.send_event(
              distinct_id: "123",
              event_name: "page_view",
              record: screener,
              controller: controller_double
            )
            expect(fake_tracker).to have_received(:track).with(
              "123",
              "page_view",
              {
                record_type: "Screener",
                record_id: screener.id,
                controller_name: "Homepage",
                controller_action: "HomepageController#index",
                locale: :en,
                referrer: "duckduckshrimp.com",
                utm_source: "duckduckshrimp"
              }
            )
          end

          it "sends custom data with the rest of the event data" do
            controller_double = instance_double(HomepageController)
            allow(controller_double).to receive(:class).and_return HomepageController
            allow(controller_double).to receive(:action_name).and_return "update"
            allow(controller_double).to receive(:utms_and_referrer).and_return({})

            MixpanelService.send_event(
              distinct_id: "123",
              event_name: "page_submit",
              data: {state: "NC", county: "Anson County"},
              controller: controller_double
            )
            expect(fake_tracker).to have_received(:track).with(
              "123",
              "page_submit",
              hash_including(
                state: "NC",
                county: "Anson County",
                controller_name: "Homepage",
                locale: :en
              )
            )
          end
        end
      end
    end
  end
end
