package main

import (
	"std"

	"gno.land/p/demo/testutils"
	"gno.land/r/demo/users"
)

const admin = std.Address("g1us8428u2a5satrlxzagqqa5m6vmuze025anjlj")

func main() {
	caller := std.GetOrigCaller() // main
	// as admin, grant invites to unregistered user.
	std.TestSetOrigCaller(admin)
	users.GrantInvites(caller.String() + ":1")
	println("done")
}

// Error:
// invalid user g17rgsdnfxzza0sdfsdma37sdwxagsz378833ca4
