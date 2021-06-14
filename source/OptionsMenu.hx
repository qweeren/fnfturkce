package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Oynanis", [
			new DFJKOption(controls),
			new DownscrollOption("Notalarin yönünü degistirir."),
			new GhostTapOption("Hayalet tiklama bos bir yöne tikladiginda sana miss vermez."),
			new Judgement("Tiklama zamanlarini degistir (SOL yada SAg)"),
			#if desktop new FPSCapOption("FPSini sinirla"),
			#end
			new ScrollSpeedOption("Kaydirma hizini degistir (1 = Orjinal)"),
			new AccuracyDOption("Isabetinin nasil hesaplanicagini degistir."),
			new ResetButtonOption("R ye tiklaninca sarkinin tekrar etmesini aç."),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Tiklayip sürükleyerek oyunu özellestir")
		]),
		new OptionCategory("Gorunum", [
			#if desktop
			new DistractionsAndEffectsOption("Sahnedeki karmasik olaylari kapat ki dikkatin dagilmasin."),
			new RainbowFPSOption("FPS Göstergesini rengarenk yapar."), new AccuracyOption("Isabet Göstergesini açar."),
			new NPSDisplayOption("Anlik kaç notaya bastigini gösterir."), new SongPositionOption("Şarkıda ne kadar ilerlediğini gösterir (çubukla)"),
			new CpuStrums("CPU's strumline lights up when a note hits it."),
			#else
			new DistractionsAndEffectsOption("Sahnedeki karmasik olaylari kapat ki dikkatin dagilmasin.")
			#end
		]),
		new OptionCategory("Diger", [
			#if desktop new FPSOption("FPS sayacini aç"), new ReplayOption("Tekrarlari görüntüle"),
			#end
			new FlashingLightsOption("Yanip sönen ve epilepsiye sebep olabilecek görüntüleri aç kapat."),
			new WatermarkOption("Oyundaki bütün filigranlari kapatir."),
			new BotPlay("Bot ile sarkilari otomatik oynatin.")
		])
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;

	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	override function create()
	{
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height
			+ 40, 0,
			"Kaydirma (Sol, Sag, Shift ile hassas): "
			+ HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
			+ " - Açiklama - "
			+ currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		super.create();
	}

	var isCat:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				curSelected = 0;
			}
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);

			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.pressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - Açiklama- " + currentDescription;
				else
					versionShit.text = "Kaydirma (Sol, Sag Shift ile hassas): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Açiklama- "
						+ currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
			}

			if (controls.RESET)
				FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press())
					{
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
						ctrl.isMenuItem = true;
						grpControls.add(ctrl);
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
					curSelected = 0;
				}
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end

		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Lütfen kategori seçin";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - Açiklama- " + currentDescription;
			else
				versionShit.text = "Kaydirma (Sol, Sag Shift ile hassas): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Açiklama- "
					+ currentDescription;
		}
		else
			versionShit.text = "Kaydirma (Sol, Sag Shift ile hassas): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Açiklama- "
				+ currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
