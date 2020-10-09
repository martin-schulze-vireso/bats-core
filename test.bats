setup() {
	read -p $'Input your name:' -r name
	export name
}

@test "test" {
	[[ "$name" == "Test" ]]
}
