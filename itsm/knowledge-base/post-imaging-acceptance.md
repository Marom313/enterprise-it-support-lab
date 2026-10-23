# Post-imaging acceptance gate

Status: Draft learning procedure — Requires Windows Lab Validation.

Run `Test-LabDeployment.ps1` on the imaged test machine using the expected name,
domain and approved service target. Keep JSON in private outputs. Review Fail,
Unknown and Review results individually; the validator never repairs the machine.

Complete Windows Update review, driver inspection, encryption verification and
application launch manually. Record image version, target asset, operator, test
date and user acceptance. Do not declare deployment successful from a parser test,
an example JSON file or registry detection of installed applications.
