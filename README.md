# ExBanking

[Project description is mentioned here.](https://coingaming.github.io/elixir-test/)

Below, I've explained how I achieved the mentioned performance point.

## Performance

> In every single moment of time the system should handle 10 or less operations for every individual user (user is a string passed as the first argument to API functions). If there is any new operation for this user and he/she still has 10 operations in pending state - new operation for this user should immediately return too_many_requests_to_user error until number of requests for this user decreases < 10

* Number of user request is controlled by **UserRequestCounter** `ets` table. Where, `read_concurrecy` opiton set as true. So, we get better performance over the concurrent operations.
* User request check-out and check-in are managed in [UserRequestManager](lib/ex_banking/accounts/user_request_manager.ex) module by `manage_request/2/3` function.
* So, once the count reaches 10, it return error until any of the running processing is finished. The case is tested in this unit test case [UserRequestManagerTest](test/ex_banking/accounts/user_request_manager_test.exs)

> The system should be able to handle requests for different users in the same moment of time

* Thanks to that, we already have [Registry](https://hexdocs.pm/elixir/1.13.4/Registry.html)
* Which runs on highly concurrent environments with thousands or millions of entries.
* By using Registry, we are handling different users in the same.

> Requests for user A should not affect to performance of requests to user B (maybe except send function when both A and B users are involved in the request)

* Since, Registry reads all the user pid by using `ets` table. It's highly concurrent and independent.
* So, we every light weight process are spawned separatly and efficiently performed by Beam scheduler.
