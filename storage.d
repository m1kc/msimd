void initStorage()
{
}

bool accountExists(string id)
{
	return true;
}

bool passwordIsValid(string id, string pass)
{
	return true;
}

void createAccount(string id, string pass)
{
}

string getContactsAsIni(string id)
{
	return "[group1]
m1kc=m1kc
Solkin=Solkin
[group2]
Ku-Kluks-Klan=kkk
Упячка=upyachka
";

}

void addContact(string account, string id)
{
}

bool contactExists(string account, string id)
{
	return true;
}

void renameContact(string account, string id1, string id2)
{
}

void removeContact(string account, string id)
{
}

string getGroupsAsString(string account)
{
	return "group1|group2";
}

bool groupExists(string account, string groupName)
{
	return true;
}

void renameGroup(string account, string name1, string name2)
{
}

void removeGroup(string account, string groupName)
{
}
