# Packet Fields

## Fields that are missing

The following fields have not yet been added to the schema. There are placeholders in this document that can be replaced once the real field names are set:

- `MISSING_in_drug_or_alcohol_program` - Participating regularly in an alcohol or drug treatment program.
- `MISSING_enrolled_in_education` - Enrolled in a school, training program, or institution of higher education at least half time.
- `MISSING_working_30_or_more_hours` - Working at least 30 hours a week.
- `MISSING_earnings_per_week` - Earning at least $217.50 a week, averaged monthly, from work.
- `MISSING_seasonal_worker` - Seasonal or migrant farmworker under an agreement or contract to start work within the next 30 days.

## Fields that have the same name as the schema

- `birth_date` - NOTE: Output should be formatted as `DD/MM/YYYY`.

## Fields that are derived from database fields

### `full_name`

`full_name` should be `first_name` joined with `last_name` by a single space.

Example:
  - `first_name` = `Peter`
  - `last_name` = `Parker`
  - `full_name` = `Peter Parker`

### `general_work_requirements_exemptions`

This field should be a summary of general work requirements exemptions. If any of the following conditions are TRUE, the field should be filled out. Otherwise, it should be blank.

- `caring_for_child_under_6` = `true`
- `caring_for_disabled_or_ill_person` = `true`
- `has_unemployment_benefits` = `true`
- `MISSING_in_drug_or_alcohol_program` = `true`
- `MISSING_enrolled_in_education` = `true`
- `MISSING_working_30_or_more_hours` = `true`
- `MISSING_earnings_per_week` = `true`

If filled out, this field should start with the following text:

> General Work Requirement Exemptions

Based on the conditions above, a list of bullets should be added to the box.

If `caring_for_child_under_6` = `true`, add the following:

> - Caring for a child under 6 years old - 7 CFR 273.7(b)(1)(iv)

If `caring_for_disabled_or_ill_person` = `true`, add the following:

> - Caring for an incapacitated person - 7 CFR 273.7(b)(1)(iv)

If `has_unemployment_benefits` = `true`, add the following:

> - Currently getting unemployment benefits or has applied for unemployment benefits - 7 CFR 273.7(b)(1)(v)

If `MISSING_in_drug_or_alcohol_program` = `true`, add the following:

> - Participating regularly in an alcohol or drug treatment program - 7 CFR 273.24(c)(2)

If `MISSING_enrolled_in_education` = `true`, add the following:

> - Enrolled in a school, training program, or institution of higher education at least half-time - 7 CFR 273.7(b)(1)(viii)

If `MISSING_working_30_or_more_hours` = `true`, add the following:

> - Working at least 30 hours a week - 7 CFR 273.7(b)(1)(vii)

If `MISSING_earnings_per_week` = `true`, add the following:

> - Earning at least $217.50 a week, averaged monthly, from work - 7 CFR 273.7(b)(1)(vii)

### `abawd_work_requirements_exemptions`

This field should be a summary of ABAWD work requirements exemptions. If any of the following conditions are TRUE, the field should be filled out. Otherwise, it should be blank.

- `has_child` = `true`
- `is_pregnant` = `true`
- `receiving_benefits_disability_pension` = `true`
- `receiving_benefits_insurance_payments` = `true`
- `receiving_benefits_none` = `true`
- `receiving_benefits_other` = `true`
- `receiving_benefits_ssdi` = `true`
- `receiving_benefits_ssi` = `true`
- `receiving_benefits_veterans_disability` = `true`
- `receiving_benefits_workers_compensation` = `true`
- `is_american_indian` = `true`
- `MISSING_seasonal_worker` = `true`
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

If `MISSING_seasonal_worker` = `true`, add the following:

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


