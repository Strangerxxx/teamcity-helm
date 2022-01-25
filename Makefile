.PHONY: cleanup
cleanup:
	rm -rf charts/teamcity/charts/*.tgz

.PHONY: dep-update
dep-update:
	helm dependency update charts/teamcity

teamcity.%.yaml: cleanup dep-update
	helm template teamcity charts/teamcity --skip-tests --dependency-update -f ./charts/teamcity/values.full-stack.yaml -f ./values.$*.yaml > $@

install-kind: teamcity.kind.yaml
	kubectl apply -f teamcity.kind.yaml
