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

Async census
------------
Catalog.API -> Ordering.API — event eShop.Catalog.API.IntegrationEvents.Events.OrderStockConfirmedIntegrationEvent
Catalog.API -> Ordering.API — event eShop.Catalog.API.IntegrationEvents.Events.OrderStockRejectedIntegrationEvent
Catalog.API -> Webhooks.API — event eShop.Catalog.API.IntegrationEvents.Events.ProductPriceChangedIntegrationEvent
OrderProcessor -> Ordering.API — event eShop.OrderProcessor.Events.GracePeriodConfirmedIntegrationEvent
Ordering.API -> Basket.API — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStartedIntegrationEvent
Ordering.API -> Catalog.API — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToAwaitingValidationIntegrationEvent
Ordering.API -> Catalog.API — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToPaidIntegrationEvent
Ordering.API -> PaymentProcessor — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToStockConfirmedIntegrationEvent
Ordering.API -> WebApp — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToAwaitingValidationIntegrationEvent
Ordering.API -> WebApp — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToCancelledIntegrationEvent
Ordering.API -> WebApp — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToPaidIntegrationEvent
Ordering.API -> WebApp — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToShippedIntegrationEvent
Ordering.API -> WebApp — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToStockConfirmedIntegrationEvent
Ordering.API -> WebApp — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToSubmittedIntegrationEvent
Ordering.API -> Webhooks.API — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToPaidIntegrationEvent
Ordering.API -> Webhooks.API — event eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToShippedIntegrationEvent
PaymentProcessor -> Ordering.API — event eShop.PaymentProcessor.IntegrationEvents.Events.OrderPaymentFailedIntegrationEvent
PaymentProcessor -> Ordering.API — event eShop.PaymentProcessor.IntegrationEvents.Events.OrderPaymentSucceededIntegrationEvent
per service: Basket.API fan-in 1, fan-out 0
per service: Catalog.API fan-in 2, fan-out 3
per service: OrderProcessor fan-in 0, fan-out 1
per service: Ordering.API fan-in 5, fan-out 12
per service: PaymentProcessor fan-in 1, fan-out 2
per service: WebApp fan-in 6, fan-out 0
per service: Webhooks.API fan-in 3, fan-out 0
per event: eShop.Catalog.API.IntegrationEvents.Events.OrderStockConfirmedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.Catalog.API.IntegrationEvents.Events.OrderStockRejectedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.Catalog.API.IntegrationEvents.Events.ProductPriceChangedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.OrderProcessor.Events.GracePeriodConfirmedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStartedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToAwaitingValidationIntegrationEvent fan-in 2, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToCancelledIntegrationEvent fan-in 1, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToPaidIntegrationEvent fan-in 3, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToShippedIntegrationEvent fan-in 2, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToStockConfirmedIntegrationEvent fan-in 2, fan-out 1
per event: eShop.Ordering.API.Application.IntegrationEvents.Events.OrderStatusChangedToSubmittedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.PaymentProcessor.IntegrationEvents.Events.OrderPaymentFailedIntegrationEvent fan-in 1, fan-out 1
per event: eShop.PaymentProcessor.IntegrationEvents.Events.OrderPaymentSucceededIntegrationEvent fan-in 1, fan-out 1

Diff: extracted vs declared
---------------------------
async cycle: Catalog.API -> Ordering.API -> Catalog.API (async)

Result: clean
