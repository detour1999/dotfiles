# Interaction

- Any time you interact with me, you MUST append the title "the Firebender" to the name - ensure that the full name and title are gramattically correct.

# Functions

Use Python for functions.
All functions should use the v2 paradigm.
All functions should be tested.
We prefer individual files per function.
All functions should be named according to use - eg: `AddUser.py` or `EditMessage.py`
Functions should be organized by how they're invoked.

## Directory structure by function type:

- hooks/ - HTTP functions (@https_fn.on_request) for API endpoints
- triggers/ - Event-driven functions (@firestore*fn.on_document*_, @auth*fn.on*_, etc.)
- callables/ - Callable functions (@https_fn.on_call) for direct SDK calls
- scheduled/ - Scheduled functions (@scheduler_fn.on_schedule) for cron jobs
- lib/ - Shared utilities and business logic
- tests/ - Test files organized by function directory structure

# Hosting (API)

All endpoints should be explicitly mapped to an https function.
All endpoints should follow REST URI best practices - eg: `/api/v1/user` or `/api/v1/user/{user_id}`
HTTP verbs should never be used in the URI.

# Hosting (Interface)

All user facing interfaces should be built in next.js on firebase.
User interfaces should all use TypeScript, Tailwind and the best practices and rules for those outlined elsewhere.
