# macro $(slot) $(item) $(id) $(type) $(menu) $(x) $(y) $(z)
$item replace block $(x) $(y) $(z) container.$(slot) with $(item)[custom_data={guikit:{widget:1,type:"$(type)",id:"$(id)",pack:"guikit",menu:"$(menu)"}},max_stack_size=1]
