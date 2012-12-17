/*
 * inifile.d
 *
 * Copyright 2012 m1kc <m1kc@yandex.ru>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */

/**
 * Authors: m1kc [m1kc@yandex.ru]
 * Date: December 17, 2012
 * License: GNU/GPL v2 or higher
 * 
 * Standards:
 * Supports
 * blank lines;
 * semicolon (;) and the number sign (#) comments;
 * colon (:) as a key-value delimitier;
 * implicit [global] section;
 * duplicate sections are merged;
 * implementation is case sensitive;
 * invalid lines are simply ignored.
 */
module inifile;

import std.string;

/// Represents an INI file.
public class IniFile
{
	private string[string][string] data;
	private string last = "global";

	/// Set a group we are working with. If it doesn't exist, it will
	/// be created when you'll add an item to it. If not set,
	/// "global" is used.
	public void setGroup(string w)
	{
		last = w;
	}

	/// Removes a group and all its elements. Note that current group
	/// remains the same and will be re-created when you will add an
	/// item to it.
	public void removeGroup(string w)
	{
		data.remove(w);
	}

	/// Sets an item's value in the current group. If specified key
	/// doesn't exist, it will be created.
	public void setItem(string key, string value)
	{
		data[last][key] = value;
	}

	/// Sets an item's value. If specified key doesn't exist, it will
	/// be created. If specified group doesn't exist, it will be
	/// created too.
	public void setItem(string group, string key, string value)
	{
		data[group][key] = value;
	}

	/// Removes an item in the current group.
	public void removeItem(string key)
	{
		data[last].remove(key);
	}

	/// Removes an item in specified group. This group must exist,
	/// or an error will occur.
	public void removeItem(string group, string key)
	{
		data[group].remove(key);
	}

	/// Gets an item's value in the current group.
	public string get(string key)
	{
		return data[last][key];
	}

	/// Gets an item's value in specified group. This group must exist,
	/// or an error will occur.
	public string get(string group, string key)
	{
		return data[group][key];
	}

	/// Returns a textual representation of stored data in the INI
	/// format.
	public string serialize()
	{
		string result = "";
		foreach (string name, string[string] items; data)
		{
			result ~= ("[" ~ name ~ "]\n");
			foreach(string key, string value; items)
			{
				result ~= (key ~ "=" ~ value ~ "\n");
			}
		}
		return result;
	}

	/// Parses a data in the INI format. Consequential parsing of
	/// multiple files isn't a problem.
	public void parse(string input)
	{
		foreach (string s; splitLines(input))
		{
			// blank line
			if (s.length==0) continue;
			// comment
			if (s[0]==';') continue;
			if (s[0]=='#') continue;

			// header
			if (s[0]=='[' && s[$-1]==']')
			{
				setGroup(s[1..$-1]);
				continue;
			}

			if (s.indexOf('=') != -1)
			{
				// key=value
				auto tmp = s.split("=");
				setItem(tmp[0], tmp[1]);
				continue;
			}
			else if (s.indexOf(':') != -1)
			{
				// key:value
				auto tmp = s.split(":");
				setItem(tmp[0], tmp[1]);
				continue;
			}
			else
			{
				// invalid line
			}
		}
	}
}
