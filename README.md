Automatic 2-day HCCS
=====

What this?
----------------
This is a KoLmafia script to automatically complete the Community Service challenge path in Hardcore within two days. Or attempt to, anyway. It largely follows yojimbos_law's 2-day HCCS guide, located here: http://forums.kingdomofloathing.com/vb/showpost.php?p=4769933&postcount=345

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
- Ascend as a Muscle moon sign (in other words, have access to the friendly Degrassi Knoll)
- Have the skills Summon Smithsness, Ode To Booze and Advanced Saucecrafting available
- Have Chateau Mantegna access, Clan V.I.P. lounge access (with speakeasy/hotdogs), and the Deck of Every Card.

It also expects that you, before ascending:
- Have a ceiling fan in the chateau
- Have a painting of a dairy goat in the chateau
- Chose astral pilsners for your consumables

If that's all you have it almost certainly will fail to hit 2-day, but that's the basic stuff needed to run it.

Anything else I should know?
----------------
Yes: run at your own risk. At least for now, I am not all that confident in the script's efficacy or even ability to run without bugging out. It has successfully completed a fully automatic 2-day HCCS for me, but only just barely and I have a lot of stuff. It also has not had many test runs done either, so yeah. Code contributions from more skilled coders than I would be welcome :)

Oh, also, KoLmafia often doesn't realize you actually have the charters unlocked, and as such the script will skip any charters that mafia erroneously thinks you don't have. To fix this, go to [your KoLmafia installation folder]\\settings\\[your username]_prefs.txt, and inside that file search for the variables "stenchAirportAlways" (Dinsey), "hotAirportAlways" (volcano), "spookyAirportAlways" (Conspiracy), and "sleazyAirportAlways" (beach); if any of those are set to "false" when in reality you actually have them, set them to "true" and save the file. Tada. Once you do this once you will never have to do it again, so I'd recommend checking this before you run it the first time.
