# frozen_string_literal: true

require "i18n/tasks"

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  it "does not have unused keys other than 2 known" do
    # there is 1 unused key across both locales, general.char_counter.remaining, that is
    # pluralized, and i18n unused will not ignore them. The documentation is unclear on
    # how this should work or not, but rather than fight with ignoring them for now, we
    # know they will cause this to fail when checking if empty, so we can just declare
    # these 2 known keys and if the number increases, that's the issue! 
    expect(unused_keys.count).to eq(2),
      "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  it "files are normalized" do
    non_normalized = i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize' to fix"
    expect(non_normalized).to be_empty, error_message
  end

  it "does not have inconsistent interpolations" do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
