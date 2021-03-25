production:
	@argocd app create $@ \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/syscrest/argocd-demo.git \
    --path apps \
	--config-management-plugin helmfile

pre-production:
	@argocd app create $@ \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/cwusyscrest/argocd-demo-helmfile.git \
    --path apps \
	--config-management-plugin helmfile

sync-pre-production:
	@argocd app sync pre-production
	@argocd app sync -l argocd.argoproj.io/instance=pre-production

sync-production:
	@argocd app sync production
	@argocd app sync -l argocd.argoproj.io/instance=production

deploy: production pre-production
sync: sync-production

# delete-pre-production:
# 	@argocd app delete pre-production

delete-production:
	@argocd app delete production

delete: delete-production

.PHONY: production sync-production \
	delete-pre-production delete-production \
	pre-production sync-pre-production \
	deploy sync delete \
	init deinit \
	init-argocd deinit-argocd \
	watch

init: init-argocd
deinit: delete deinit-argocd

init-argocd:
	@kubectl create namespace argocd
	@helm install argocd --namespace argocd argo-cd-local -f argocd-init/values.yaml
	@echo "Default argocd admin password, be sure to change it! '$$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)'"

deinit-argocd:
	@helm uninstall argocd --namespace argocd
	@kubectl delete namespace argocd

watch:
	@watch "kubectl get pods -A --sort-by=status.startTime | awk 'NR<2{print \$$0;next}{print \$$0| \"tail -r\"}'"

redeploy-argo:
	helm uninstall argocd --namespace argocd
	helm install argocd --namespace argocd argo-cd-local -f argocd-init/values.yaml
 