| Target module | Used by module | APIs used |
| --- | --- | --- |
| `Catalog` | `API` | `CatalogAI`, `ICatalogAI` |
| `EventBus` | `Extensions` | `EventBusSubscriptionInfo`, `IIntegrationEventHandler` |
| `EventBus` | `OrderProcessor` | `IEventBus`, `IntegrationEvent` |
| `EventBus` | `WebApp` | `IIntegrationEventHandler`, `IntegrationEvent` |
| `EventBusRabbitMQ` | `Extensions` | `EventBusOptions`, `RabbitMQEventBus`, `RabbitMQTelemetry` |
| `Ordering` | `Infrastructure` | `OrderingContext` |
| `WebAppComponents` | `HybridApp` | `CatalogBrand`, `CatalogItem`, `CatalogItemType`, `CatalogResult`, `ICatalogService`, `IProductImageUrlProvider` |
| `WebAppComponents` | `WebApp` | `CatalogItem`, `CatalogService`, `ICatalogService`, `IProductImageUrlProvider` |
note: this view shows no roles by decision (a role is not a usage fact) — explained in 'archspec help roles'
