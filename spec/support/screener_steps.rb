module ScreenerSteps
  EMAIL = "hi@example.com"
  # -- Homepage ---------------------------------------------------------------
  def step_homepage
    visit root_path
    expect(page).to have_selector("h1", text: I18n.t("views.homepage.index.title"))
    click_on I18n.t("views.homepage.fill_out_form")
    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
  end

  # -- Age screening ----------------------------------------------------------
  def step_date_of_birth(year:)
    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select year.to_s, from: "Year"
    click_on I18n.t("general.continue")
  end

  # -- Common exemption questions (tribe → migrant farmworker) ----------------
  # caring: :disabled_or_ill or :none
  def step_exemption_questions(caring:)
    expect(page).to have_selector("h1", text: I18n.t("views.tribe_or_nation.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.living_with_someone.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.caring_for_someone.edit.title"))
    case caring
    when :disabled_or_ill
      check I18n.t("views.caring_for_someone.edit.disabled_or_ill_person")
      fill_in I18n.t("views.caring_for_someone.edit.additional_care_info"), with: "lots of care"
    when :none
      check I18n.t("general.none_of_the_above")
    end
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.pregnancy.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.unemployment.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.disability_benefits.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.migrant_farmworker.edit.title"))
    click_on I18n.t("general.negative")
  end

  # -- School enrollment ------------------------------------------------------
  def step_school_enrollment(answer:)
    expect(page).to have_selector("h1", text: I18n.t("views.school_enrollment.edit.title"))
    click_on (answer == :yes) ? I18n.t("general.affirmative") : I18n.t("general.negative")
  end

  # -- Alcohol treatment ------------------------------------------------------
  def step_alcohol_treatment_program(answer:, program_name: nil)
    expect(page).to have_selector("h1", text: I18n.t("views.alcohol_treatment_program.edit.title"))
    if answer == :yes
      choose I18n.t("general.affirmative")
      fill_in I18n.t("views.alcohol_treatment_program.edit.alcohol_treatment_program_name_label"), with: program_name
    else
      choose I18n.t("general.negative")
    end
    click_on I18n.t("general.continue")
  end

  # -- Preventing work section ------------------------------------------------
  # situations: array of symbols (:medical_condition, :place_to_sleep, :other) or :none
  # details: required text when situations is not :none (preventing_work_details page)
  def step_prevention_section(situations:, details: nil)
    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_situations.edit.title"))
    if situations == :none
      check I18n.t("general.none_of_the_above")
    else
      Array(situations).each do |situation|
        case situation
        when :medical_condition then check id: "screener_preventing_work_medical_condition"
        when :place_to_sleep then check I18n.t("views.preventing_work_situations.edit.preventing_work_place_to_sleep")
        when :other then check I18n.t("views.preventing_work_situations.edit.other")
        end
      end
      if Array(situations).include?(:other)
        fill_in I18n.t("views.preventing_work_situations.edit.preventing_work_write_in"), with: "my spoon carving side hustle"
      end
    end
    click_on I18n.t("general.continue")

    return unless details

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_details.edit.title"))
    fill_in "preventing_work_additional_info", with: details
    click_on I18n.t("general.continue")
  end

  # -- Work activity section (no regular exemption only) ----------------------
  def step_work_activity_section(hours:, earnings:)
    expect(page).to have_selector("h1", text: I18n.t("views.wages_hours_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.employment.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.employment.edit.working_hours_label"), with: hours
    fill_in I18n.t("views.employment.edit.working_weekly_earnings_label"), with: earnings
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.community_service.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.training_program.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")
  end

  # -- Personal info section --------------------------------------------------
  # check_phone_toggle: verify the SMS consent legend appears only after a full phone number
  def step_personal_info_section(first_name:, last_name:, phone:, email:, ssn:, check_phone_toggle: false)
    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.basic_info_milestone.edit.title_html")))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_details.edit.title"))
    fill_in I18n.t("views.basic_info_details.edit.first_name_label"), with: first_name
    fill_in I18n.t("views.basic_info_details.edit.last_name_label"), with: last_name

    if check_phone_toggle
      expect(page).to_not have_selector("legend", text: I18n.t("views.basic_info_details.edit.consented_to_texts.label"))
      fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: "415-816"
      expect(page).to_not have_selector("legend", text: I18n.t("views.basic_info_details.edit.consented_to_texts.label"))
      fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: phone
      expect(page).to have_selector("legend", text: I18n.t("views.basic_info_details.edit.consented_to_texts.label"))
    else
      fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: phone
    end
    choose I18n.t("views.basic_info_details.edit.consented_to_texts.affirmative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.email.edit.title"))
    fill_in I18n.t("views.email.edit.email"), with: email
    fill_in I18n.t("views.email.edit.email_confirmation"), with: email
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_case_number.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_ssn.edit.title"))
    fill_in I18n.t("views.basic_info_ssn.edit.ssn_label"), with: ssn
    click_on I18n.t("general.continue")
  end

  # -- Signature and download -------------------------------------------------

  # with_back_nav: exercises back-navigation through case number entry (regular exemption only)
  # check_earnings_exemption: asserts earnings exemption copy on the signature page
  def step_signature_and_download(signature:, email:, with_back_nav: false, check_earnings_exemption: false)
    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    expect(page).to have_content(I18n.t("views.signature.edit.exemption_working_30_hours")) if check_earnings_exemption
    fill_in I18n.t("views.signature.edit.signature_label"), with: signature
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.download_form.edit.title_sent", email: email))

    return unless with_back_nav

    click_on I18n.t("general.back")
    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    click_on I18n.t("general.back")
    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_ssn.edit.title"))
    click_on I18n.t("general.back")
    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_case_number.edit.title"))
    fill_in I18n.t("views.basic_info_case_number.edit.case_number_label"), with: "ABC-123"
    click_on I18n.t("general.continue")
    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    click_on I18n.t("general.continue")
    expect(page).to have_selector("h1", text: I18n.t("views.download_form.edit.title_sent", email: email))
  end

  # -- Feedback section (regular exemption only) ------------------------------
  def step_feedback_section
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.proof_guidance.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.new_response_with_feedback.edit.title"))
    choose I18n.t("views.new_response_with_feedback.edit.very_easy")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.feedback_confident.edit.title"))
    choose I18n.t("views.feedback_confident.edit.very")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.feedback_result.edit.title"))
    check I18n.t("views.feedback_result.edit.email_results")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.new_response.edit.title"))
    click_on I18n.t("general.check_work_rules_for_someone_else")

    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
  end
end
