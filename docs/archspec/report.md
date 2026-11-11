Architecture report
===================

Spec: architecture.spec.toml (language: csharp)

adjudicated against BUILT tree

Metrics
-------
components:          27
units:               25
edges (internal):    51
edges (external):    72
cycles detected:     1

Roles
-----
facades: Ordering::Infrastructure, eShop::EventBus, eShop::Ordering
composition roots: Catalog::API, Identity::API, Webhooks::API, eShop::Application, eShop::ClientApp, eShop::HybridApp, eShop::Ordering::API, eShop::WebApp, eShop::WebhookClient

Diff: extracted vs declared
---------------------------
no violations found

1 cycle among 57 module facts; exempt: 1, violating: 0; territory: 27/27 modules

Result: clean
