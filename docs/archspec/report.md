Architecture report
===================

Spec: architecture.spec.toml (language: csharp)

adjudicated against BUILT tree

Environment lines by class
--------------------------
test-gated unit   9
test-gated units: 9

Metrics
-------
components:          22
units:               20
edges (internal):    35
edges (external):    67
cycles detected:     0

Roles
-----
facades: Ordering::Infrastructure, eShop::EventBus, eShop::Ordering
composition roots: Catalog::API, Identity::API, Webhooks::API, eShop::Basket, eShop::ClientApp, eShop::HybridApp, eShop::Ordering::API, eShop::WebApp, eShop::WebhookClient

Diff: extracted vs declared
---------------------------
no violations found

Result: clean
