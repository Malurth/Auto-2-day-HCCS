// Full credit to bumcheekcity for starting point
// Adapted from relay_bumcheekascend.ash

script "relay_AutoHCCS.ash";

record setting {
	string name;
	string type;
	string description;
	string value;
	string c;
	string d;
	string e;
};

setting[int] s;
string[string] fields;
boolean success;

boolean[string] tests = $strings[Equip , HP, Muscle, Myst, Moxie, Weight, WeaponDmg, SpellDmg, NonCombat, Item, HotRes];

boolean load_current_map(string fname, setting[int] map) {
	file_to_map(fname+".txt", map);
	
	if (count(map) == 0) return false;
	
	return true;
}

void main() {
	load_current_map("AutoHCCS_settings", s);
	fields = form_fields();
	success = count(fields) > 0;
	
	foreach x in fields {
		set_property(x, fields[x]);
	}
	
	writeln("<html><head><title>AutoHCCS Settings</title></head><body style=\"font-family: Arial;\"><form action='' method='post'><center><table cellspacing=0 cellpadding=0><tr><td style=\"color: white;\" align=\"center\" bgcolor=\"blue\" colspan=\"4\"><b>AutoHCCS Settings 0.2</b></td></tr><tr><td style=\"padding: 5px; border: 1px solid blue;\"><center><table><tr><td colspan='4'><center><table><tr><td valign=top></td><td valign=top><center><b>Configure Settings</b></center><p>Here are some cool settings!  Configure them!</td></tr></table></center></td></tr><tr><th>Name of Setting:</th><th>Value:</th><th>Test:</th><th>Description:</th></tr>");
	foreach x in s {
		switch (s[x].type) {
			case "boolean" :
				write("<tr><td>"+s[x].name+"</td><td><select name='"+s[x].name+"'>");
				if (get_property(s[x].name) == "true") {
					write("<option value='true' selected='selected'>true</option><option value='false'>false</option>");
				} else {
					write("<option value='true'>true</option><option value='false' selected='selected'>false</option>");
				}
				writeln("</td><td></td><td>"+s[x].description+"</td></tr>");
			break;
			
      case "item" :
        writeln("<tr><td>"+s[x].name+"</td><td><input type='text' name='"+s[x].name+"' value='"+get_property(s[x].name)+"' /></td><td>");
        write("<select name='"+s[x].name+"_test"+"'>");
        foreach i in tests {
          if(i == get_property(s[x].name + "_test")) {
            write("<option value='" + get_property(s[x].name + "_test") + "' selected='selected'>" + get_property(s[x].name + "_test") + "</option>");
          } else {
            write("<option value='" + i + "'>" + i + "</option>");
          }
        }
        writeln("</td><td>"+s[x].description+"</td></tr>");
      break;
      
      
      
			default :
				writeln("<tr><td>"+s[x].name+"</td><td><input type='text' name='"+s[x].name+"' value='"+get_property(s[x].name)+"' /></td><td></td><td>"+s[x].description+"</td></tr>");
			break;
		}
	}
	writeln("<tr><td colspan='3'><input type='submit' name='' value='Save Changes' /></td></tr></form>");
	writeln("</body></html>");
}
