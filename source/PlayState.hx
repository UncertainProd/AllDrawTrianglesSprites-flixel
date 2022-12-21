package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxStrip;
import flixel.addons.display.FlxSliceSprite;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.editors.spine.FlxSpine;
import flixel.addons.effects.FlxClothSprite;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var background:FlxTiledSprite;
	var flag:FlxClothSprite;
	var rope:FlxClothSprite;
	var spineSprite:FlxSpine;
	var nineSlice:FlxSliceSprite;
	var strip:FlxStrip;

	var shadersActive:Bool = false;

	override public function create()
	{
		super.create();

		background = makeTiledSprite();
		add(background);

		flag = makeClothSprite();
		add(flag);

		rope = makeRopeClothSprite();
		add(rope);

		nineSlice = makeSliceSprite();
		add(nineSlice);

		spineSprite = makeSpineBoy();
		add(spineSprite);

		strip = makeStrip();
		add(strip);
	}

	function makeTiledSprite()
	{
		return new FlxTiledSprite("assets/images/placeholder.png", 500, 200);
	}

	function makeClothSprite()
	{
		var flag = new FlxClothSprite(FlxG.width / 2 - 105, 10, "assets/images/flag.png");
		flag.pinnedSide = NONE;
		flag.meshScale.set(1.5, 1);
		flag.setMesh(15, 10, 0, 0, [0, 14]);
		flag.iterations = 8;
		flag.maxVelocity.set(200, 200);
		flag.meshVelocity.y = 40;
		return flag;
	}

	function makeRopeClothSprite()
	{
		var rope = new FlxClothSprite(FlxG.width / 2 + 200, 10, "assets/images/rope.png", 2, 10, UP, true);
		rope.maxVelocity.set(40, 40);
		rope.meshVelocity.y = 40;
		return rope;
	}

	function makeSliceSprite()
	{
		var sliceSprite = new FlxSliceSprite('assets/images/9slicesource.png', FlxRect.weak(0, 0, 150, 150), 300, 300, FlxRect.weak(0, 0, 36, 36));
		sliceSprite.y += 200;
		return sliceSprite;
	}

	function makeStrip()
	{
		var strip:FlxStrip;
		strip = new FlxStrip();
		strip.screenCenter();
		strip.makeGraphic(100, 100, FlxColor.GREEN);
		strip.vertices = DrawData.ofArray([0.0, 0.0, 50, 0, 25, 50]);
		strip.indices = DrawData.ofArray([0, 1, 2]);
		strip.uvtData = DrawData.ofArray([0, 0, 0, 1, 1, 1.0]);
		return strip;
	}

	function makeSpineBoy()
	{
		var spineSprite = new SpineBoyTest(FlxSpine.readSkeletonData("spineboy", "spineboy", "assets/images/", 0.6), 0.5 * FlxG.width, FlxG.height);
		spineSprite.antialiasing = true;
		return spineSprite;
	}

	override public function update(elapsed:Float)
	{
		// movement
		if (FlxG.keys.anyPressed([W, UP]))
		{
			spineSprite.y -= 500 * elapsed;
		}
		if (FlxG.keys.anyPressed([S, DOWN]))
		{
			spineSprite.y += 500 * elapsed;
		}
		if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			spineSprite.x += 500 * elapsed;
			spineSprite.skeleton.flipX = false;
		}
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			spineSprite.x -= 500 * elapsed;
			spineSprite.skeleton.flipX = true;
		}

		// Apply a random wind
		if (FlxG.mouse.pressed)
		{
			flag.meshVelocity.x = FlxG.random.float(0, flag.maxVelocity.x);
			rope.meshVelocity.x = FlxG.random.float(0, rope.maxVelocity.x);
		}
		else
		{
			flag.meshVelocity.x = 0;
			rope.meshVelocity.x = 0;
		}
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE)
		{
			// toggles shaders
			if (!shadersActive)
			{
				background.shader = new GreyShader();
				flag.shader = new GreyShader();
				rope.shader = new GreyShader();
				spineSprite.shader = new GreyShader();
				nineSlice.shader = new GreyShader();
				strip.shader = new GreyShader();
				shadersActive = true;
			}
			else
			{
				background.shader = null;
				flag.shader = null;
				rope.shader = null;
				spineSprite.shader = null;
				nineSlice.shader = null;
				strip.shader = null;
				shadersActive = false;
			}
		}
	}
}

class GreyShader extends flixel.system.FlxAssets.FlxShader
{
	@glFragmentSource('
	#pragma header

	void main()
	{
		vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
		gl_FragColor = vec4((color.rrr + color.ggg + color.bbb)/3.0, 1.0) * color.a;
		// gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	}
	')
	public function new()
	{
		super();
	}
}
