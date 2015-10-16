Automatic 2-day HCCS
=====

What this?
----------------
This is a KoLmafia script to automatically complete the Community Service challenge path in Hardcore within two days. Or attempt to, anyway. It largely follows yojimbos_law's 2-day HCCS guide, located here: http://forums.kingdomofloathing.com/vb/showpost.php?p=4769933&postcount=345

I'd reccomend giving it a once-over since it details how to best prepare yourself overall, and describes how the run goes.

How use?
----------------
Install it by running this command in KoLmafia's graphical CLI:

<pre>
svn checkout https://github.com/Malurth/Auto-2-day-HCCS/branches/Release/
</pre>

Then, given you have met the prerequisites, run it (AutoHCCS.ash) from the scripts menu right after you've ascended into HCCS, and again as the first thing you do on the next day. Also, cross your fingers.

What prerequisites?
----------------
This script is quite targeted; if you don't have the right stuff/class it will immediately abort, and it will probably fail to hit 2-day if you don't have a bunch of other stuff anyway. That being said, the most basic prerequisites are:
- Ascend as a Sauceror
- Ascend with the Wallaby moon sign (well any Knoll-unlocking sign will do, but pick that one)
- Have the skills Summon Smithsness, Ode To Booze and Advanced Saucecrafting available
- Have Chateau Mantegna access, Clan V.I.P. lounge access (with speakeasy/hotdogs), and the Deck of Every Card.

It also expects that you, before ascending:
- Have your chateau prepared with a ceiling fan, foreign language tapes, a continental juice bar, and a painting of a dairy goat
- Chose astral pilsners for your consumables

If that's all you have it almost certainly will fail to hit 2-day, but that's the basic stuff needed to run it. To greatly increase your chances of completing 2-day, I highly recommend also having the Winter Garden, DNA lab, and every airplane charter other than Spring Break Beach. Some IotMs such as the Fist Turkey, Crimbo Shrub, Galloping Grill, GameInform correspondence, and a standard-compliant spleen familiar will help as well, but much less significantly. Others, like Puck-man and the Mayo clinic, while potentially helpful, are currently entirely unsupported in the script.

Anything else I should know?
----------------
Yes: run at your own risk. The script pretty stable now, and has been netting me as well as others consistent 2-dayers now, but it is still liable to bug out/malfunction or just fail to hit 2-day (for instance, by getting beaten up by the dairy goat if you don't have a few handy skills for combat). By running this script, you are accepting that risk yourself.

Speaking of getting beaten up, I suppose I should clarify combat stuff; you'll find yourself getting beaten up a lot if you don't have the right skills to keep you alive. The main combat skills are Saucegeyser/Curse of Weaksauce/Itchy Curse Finger, and if you want to survive you'll definitely want Reptilian Fortitude, Cannelloni Cocoon, +initiative% buffs (Springy Fusilli, Overdeveloped Sense of Self-Preservation, and a few others to be safe), and probably Tao of the Terrapin. Also, if you have the 70s Volcano or Dinsey, you'll want Astral Shell and Elemental Saucesphere (which save turns on the hot test anyway, so yeah). Thick-Skinned/Slimy Shoulders/Slimy Sinews also help a lot, but they're hard to get. Song of Sauce helps a lot for the surviving 70s Volcano's caldera too, since it allows Saucegeyser to do its usual damage and one-shot the monsters (they're hot-aligned so it otherwise does half damage), preventing a round of damage from the monster and the lava, but that skill is also kind of a pain to get. Finally, also tack on whatever +HP% passives you can, since they both help you survive and help a lot for the HP test.

Alternatives
----------------
If you'd like to automate a softcore run instead, you now can thanks to the efforts of RESPRiT. If you'd like to use that, toggle that functionality on from the new relay browser settings menu RESPRiT added, and list what items you'd like to pull for what tests. The menu includes a recommended pull list, so you don't have to stress about that.

If you'd still like to automate a hardcore CS run, but do it a lot more optimally/faster, Croft has published a comprehensive overhaul of the script! It now supports a sk8 gnome in the chateau painting, Puck Man, optional checkpoints where the script will abort in select areas to let you do whatever manual optimizations you may want to perform before re-running it, and myriad general optimizations. It's overall much better in nearly every regard, but it regresses some of the recent changes like the softcore functionality, and has also had much less people trying to run it as of this writing, so it's less guaranteed to be stable as this is. (I would have merged it into this script, but I don't want to potentially break things for current users, and I'd also have to merge it by hand since it's only on pastebin and I'm lazy :p). You can find his new-and-improved script at http://pastebin.com/7xXCPM3e.

