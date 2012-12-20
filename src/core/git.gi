<?xml version="1.0"?>
<api version="1.0">
	<namespace name="">
		<function name="core_retrive_all_branchs" symbol="core_retrive_all_branchs">
			<return-type type="void"/>
			<parameters>
				<parameter name="repo" type="git_repository*"/>
			</parameters>
		</function>
		<function name="show_branches" symbol="show_branches">
			<return-type type="int"/>
			<parameters>
				<parameter name="branch_name" type="char*"/>
				<parameter name="type" type="git_branch_t"/>
				<parameter name="payload" type="void*"/>
			</parameters>
		</function>
	</namespace>
</api>
