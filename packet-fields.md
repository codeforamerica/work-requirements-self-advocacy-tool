# Packet Fields

## Fields that are missing

The following fields have not yet been added to the schema. There are placeholders in this document that can be replaced once the real field names are set:

- `in_drug_or_alcohol_program` - Participating regularly in an alcohol or drug treatment program
- `enrolled_in_education` - Enrolled in a school, training program, or institution of higher education at least half time
- `earnings_per_week` - Earning at least $217.50 a week, averaged monthly, from work.
- `seasonal_worker` - Seasonal or migrant farmworker under an agreement or contract to start work within the next 30 days
- `work_hours` - Work hours reported per week
- `weekly_earn` - Wages earned per week
- `confirmation_code` - Confirmation code
- `submission_date` - Submission date
- `case_number` - Case number
- `ssn_last_4` - The last 4 digits of the SSN
- `receiving_benefits_disability_medicaid` - Disability-related Medicaid
- `details_of_care` - Details of care for disabled or ill person

## Fields that have the same name as the schema

- `birth_date`
- `phone_number`
- `email`
- `is_american_indian`
- `has_child`
- `caring_for_child_under_6`
- `caring_for_disabled_or_ill_person`
- `is_in_work_training`
- `work_training_name`
- `work_training_hours`
- `has_unemployment_benefits`
- `receiving_benefits_disability_pension`
- `receiving_benefits_insurance_payments`
- `receiving_benefits_other`
- `receiving_benefits_ssdi`
- `receiving_benefits_ssi`
- `receiving_benefits_veterans_disability`
- `receiving_benefits_workers_compensation`
- `receiving_benefits_write_in`
- `pregnancy_due_date`
- `volunteering_hours`
- `volunteering_org_name`

## Fields that are copies of other fields

- `birth_date_2` = `birth_date`

## Fields that are derived from database fields

### `full_name`

`full_name` should be `first_name` joined with `last_name` by a single space.

Example:
  - `first_name` = `Peter`
  - `last_name` = `Parker`
  - `full_name` = `Peter Parker`

### `full_name_with_middle`

`full_name_with_middle` should be `first_name` joined with `middle_name` (if it's filled out) joined with `last_name` by singled spaces.

Example:
  - `first_name` = `Peter`
  - `last_name` = `Parker`
  - `middle_name` = `Benjamin`
  - `full_name_with_middle` = `Peter Benjamin Parker`

Example:
  - `first_name` = `Peter`
  - `last_name` = `Parker`
  - `middle_name` = ``
  - `full_name_with_middle` = `Peter Parker`

### `age`

`age` should be the difference between `submission_date` and `birth_date` in years, rounded down.

Example:
  - `submission_date` = January 9, 2026
  - `birth_date` = July 13th, 1990
  - `age` = 35

### `receiving_disability_benefits`

`receiving_disability_benefits` should be `true` if **ANY** of the following are `true`:
  - `receiving_benefits_disability_pension`
  - `receiving_benefits_insurance_payments`
  - `receiving_benefits_other`
  - `receiving_benefits_ssdi`
  - `receiving_benefits_ssi`
  - `receiving_benefits_veterans_disability`
  - `receiving_benefits_workers_compensation`

### `working_30_or_more_hours`

`working_30_or_more_hours` should be `true` if `work_hours` >= 30.

### `working_or_earning`

`working_or_earning` should be `true` if **ANY** of the following conditions are `true`:
  - `working_30_or_more_hours` = `true`
  - `earnings_per_week` >= 217.50

### `is_volunteering`

`is_volunteering` should be `true` if `volunteering_hours` > 0.

### `general_work_requirements_exemptions`

This field should be a summary of general work requirements exemptions. If any of the following conditions are TRUE, the field should be filled out. Otherwise, it should be blank.

- `caring_for_child_under_6` = `true`
- `caring_for_disabled_or_ill_person` = `true`
- `has_unemployment_benefits` = `true`
- `in_drug_or_alcohol_program` = `true`
- `enrolled_in_education` = `true`
- `working_30_or_more_hours` = `true`
- `earnings_per_week` = `true`

If filled out, this field should start with the following text:

> General Work Requirement Exemptions

Based on the conditions above, a list of bullets should be added to the box.

If `caring_for_child_under_6` = `true`, add the following:

> - Caring for a child under 6 years old - 7 CFR 273.7(b)(1)(iv)

If `caring_for_disabled_or_ill_person` = `true`, add the following:

> - Caring for an incapacitated person - 7 CFR 273.7(b)(1)(iv)

If `has_unemployment_benefits` = `true`, add the following:

> - Currently getting unemployment benefits or has applied for unemployment benefits - 7 CFR 273.7(b)(1)(v)

If `in_drug_or_alcohol_program` = `true`, add the following:

> - Participating regularly in an alcohol or drug treatment program - 7 CFR 273.24(c)(2)

If `enrolled_in_education` = `true`, add the following:

> - Enrolled in a school, training program, or institution of higher education at least half-time - 7 CFR 273.7(b)(1)(viii)

If `working_30_or_more_hours` = `true`, add the following:

> - Working at least 30 hours a week - 7 CFR 273.7(b)(1)(vii)

If `earnings_per_week` = `true`, add the following:

> - Earning at least $217.50 a week, averaged monthly, from work - 7 CFR 273.7(b)(1)(vii)

### `abawd_work_requirements_exemptions`

This field should be a summary of ABAWD work requirements exemptions. If any of the following conditions are TRUE, the field should be filled out. Otherwise, it should be blank.

- `has_child` = `true`
- `is_pregnant` = `true`
- `receiving_benefits_disability_pension` = `true`
- `receiving_benefits_insurance_payments` = `true`
- `receiving_benefits_other` = `true`
- `receiving_benefits_ssdi` = `true`
- `receiving_benefits_ssi` = `true`
- `receiving_benefits_veterans_disability` = `true`
- `receiving_benefits_workers_compensation` = `true`
- `is_american_indian` = `true`
- `seasonal_worker` = `true`
- `preventing_work_domestic_violence` = `true`
- `preventing_work_drugs_alcohol` = `true`
- `preventing_work_medical_condition` = `true`
- `preventing_work_other` = `true`
- `preventing_work_place_to_sleep` = `true`

If filled out, this field should start with the following text:

> Able-Bodied Adult Without Dependents (ABAWD) Work Requirement Exemptions

Based on the conditions above, a list of bullets should be added to the box.

If `has_child` = `true`, add the following:

> - Living with a child under 14 years old - 7 USC 2015(o)(3)(C)

If `is_pregnant` = `true`, add the following:

> - Pregnant (Due: `pregnancy_due_date`) - 7 CFR 273.24(c)(6)

If **ANY** of the `receiving_benefits_*` fields are `true`, add the following:

> - Receiving a disability benefit - 7 CFR 273.24(c)(2)(i)

If `is_american_indian` = `true`, add the following:

> - A member of an Indian tribe or nation - 7 USC 2015(o)(3)(F),(G)

If `seasonal_worker` = `true`, add the following:

> - Seasonal or migrant farmworker under an agreement or contract to start work within the next 30 days. 7 CFR 273.7(b)(1)(vii)

If **ANY** of the `preventing_work_*` fields are `true`, add the following:

> - “Unfit for work” - unable to consistently work 20 hours a week (7 CFR 273.24(c)(2)) because: 

If `preventing_work_place_to_sleep` = `true`, add the following sub-bullet:

> - Does not have a regular place to sleep or shower

If `preventing_work_domestic_violence` = `true`, add the following sub-bullet:

> - Experiencing domestic violence

If `preventing_work_drugs_alcohol` = `true`, add the following sub-bullet:

> - Substance use disorder

If `preventing_work_medical_condition` = `true`, add the following sub-bullet:

> - Has a physical or mental medical condition preventing them from working at least 20 hours every week (see details on following pages).

If `preventing_work_other` = `true`, add the following sub-bullet:

> - Other

### `abawd_work_requirements_compliance`

This field should be a summary of ABAWD work requirements compliance information. If any of the following conditions are TRUE, the field should be filled out. Otherwise, it should be blank.

- (`work_hours` + `volunteering_hours` + `work_training_hours`) >= 20
- `weekly_earn` >= 217.50

If filled out, this field should start with the following text:

> `first_name` `last_name` (DOB: `birth_date`) is also reporting the following for SNAP ABAWD Work Requirements compliance:

If `work_hours` >= 20, add the following:

> - Reporting `work_hours` work hours per week - 7 CFR 273.24(a)(1)(i)

If `weekly_earn` >= 217.50, add the following:

> - Reporting `weekly_earn` in weekly gross income - 7 CFR 273.7(b)(1)(vii)

If `volunteering_hours` >= 20, add the following:

> - Participating in community service or volunteer work for `volunteering_hours` per week - 7 CFR 273.24(a)(2)(iii)

If `work_training_hours` >= 20, add the following:

> - Participating in a job or work training program for `work_training_hours` hours per week

If (`work_hours` < 20) and (`volunteering_hours` < 20) and (`work_training_hours` < 20) and (`work_hours` + `volunteering_hours` + `work_training_hours` >= 20), add the following:

> - Participating in combined work, volunteering and/or training for `work_hours + work_training_hours + volunteering_hours` hours per week -  7 CFR 273.24(a)(2)(iv)
