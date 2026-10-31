# Glossary: episode 25, Fulfillment orchestration

Terms this episode introduces. The full project glossary is `GLOSSARY.md` in the repository root.

- **Fulfilment, provisioning**: Delivering what was sold; provisioning is switching a service on.
- **Dynamic Revenue Orchestrator (DRO)**: The Revenue Management tool that turns an activated order into a plan of fulfilment work.
- **Technical product**: A product that stands for a piece of fulfilment work, not something the customer buys.
- **Decomposition**: Mapping commercial order lines to technical fulfilment lines.
- **Decomposition rule**: The rule that decides which technical product a commercial product decomposes into.
- **Fulfilment workspace, step definition group, step definition**: The place where steps are designed, the group that orders them, and a design-time step.
- **Step scope (line item, plan)**: Whether a step runs once for each order line or once for the whole plan.
- **Dependency**: A step that must finish before another can start.
- **Scenario**: The rule that picks which step group goes into a plan for a product and order action.
- **Orchestration plan**: The ordered plan of work after decomposition, with each step and its state.
- **Fallout, jeopardy, PONR, supplemental order**: A step that fails, a step at risk of being late, the point of no return after which a line cannot be cancelled, and a change to an order already submitted. These four are explained on a slide only.
