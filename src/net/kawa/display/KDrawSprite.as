/*
 * Copyright (c) 2011 Yusuke Kawasaki http://www.kawa.net/
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 */

package net.kawa.display {
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * Draw the source DisplayObject as a bitmap image to get better GPU performance.
	 * @author Yusuke Kawasaki
	 * @version 1.2.5
	 * @example
	 * Call KDrawSprite.getSprite() instead of setting cacheAsBitmapMatrix and cacheAsBitmap properties.
	 * <listing version="3.0">
	 * var sprite:Sprite = new Sprite();
	 * sprite.graphics.beginFill(0x336699);
	 * sprite.graphics.drawCircle(50, 50, 50);
	 * 
	 * // sprite.cacheAsBitmapMatrix = new Matrix(); // BEFORE
	 * // sprite.cacheAsBitmap = true;
	 * 
	 * sprite = KDrawSprite.getSprite(sprite);       // AFTER
	 * 
	 * addChild(sprite);
	 * sprite.x = 100;
	 * sprite.y = 100;
	 * sprite.scaleX = 0.5;
	 * sprite.height = 50;
	 * sprite.rotation = 1;
	 * </listing>
	 */
	public class KDrawSprite extends Sprite {
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;

		/**
		 * Creates a new KDrawSprite instance.
		 * @param autoDispose Specifies whether internal BitmapData will be disposed by KDrawSprite when removed from Stage.
		 */
		public function KDrawSprite(autoDispose:Boolean = true):void {
			bitmap = new Bitmap();
			addChild(bitmap);
			if (autoDispose) {
				addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageListener, false, 0, true);
			}
		}

		private function removedFromStageListener(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageListener);
			dispose();
		}

		/**
		 * Frees memory of the internal bitmap image. Call this when autoDispose is false.
		 */
		public function dispose():void {
			if (bitmapData) {
				bitmapData.dispose();
				bitmapData = null;
			}
		}

		/**
		 * Draws the source DisplayObject onto the internal bitmap image.
		 * @param source Source DisplayObject to draw. Ex. Sprite, Shape, etc.
		 * @param quality Rendering quality. The default is 1 (NoAA). 2 means 2x SSAA, super sampling anti-aliasing.
		 * @example
		 * <listing version="3.0">
		 * var view:KDrawSprite = new KDrawSprite();
		 * addChild(view);
		 * 
		 * var work:Sprite = new Sprite();
		 * work.graphics.beginFill(0xFFCC99);
		 * work.graphics.drawRect(0, 0, 100, 100);
		 * view.draw(work);
		 * </listing>
		 */
		public function draw(source:DisplayObject, quality:Number = 1):void {
			if (bitmapData) {
				bitmapData.dispose();
			}
			var rect:Rectangle = source.getBounds(source);
			var matrix:Matrix = new Matrix();
			matrix.tx = -rect.x;
			matrix.ty = -rect.y;
			matrix.scale(source.scaleX, source.scaleY);
			bitmapData = new BitmapData(source.width * quality, source.height * quality, true, 0);
			if (quality != 1.0) {
				matrix.scale(quality, quality);
			}
			bitmapData.draw(source, matrix, null, null, null, true);
			if (quality != 1.0) {
				var bmTemp:BitmapData = new BitmapData(source.width, source.height, true, 0);
				matrix.createBox(1.0 / quality, 1.0 / quality);
				bmTemp.draw(bitmapData, matrix, null, null, null, true);
				bitmapData.dispose();
				bitmapData = bmTemp;
			}
			bitmap.bitmapData = bitmapData;
			bitmap.x = source.x + rect.x;
			bitmap.y = source.y + rect.y;
			bitmap.alpha = source.alpha;
		}

		/**
		 * Draws the source DisplayObject as a bitmap image. Returns it as a Sprite object.
		 * @param source Source DisplayObject to draw. Ex. Sprite, Shape, etc.
		 * @param quality Rendering quality. The default is 1 (NoAA). 2 means 2x SSAA, super sampling anti-aliasing.
		 * @return A Sprite object which has a Bitmap image rendered.
		 * @example
		 * <listing version="3.0">
		 * var sprite:Sprite = new Sprite();
		 * sprite.graphics.beginFill(0x336699);
		 * sprite.graphics.drawCircle(50, 50, 50);
		 * sprite = KDrawSprite.getSprite(sprite);
		 * addChild(sprite);
		 * </listing>
		 */
		public static function getSprite(source:DisplayObject, quality:Number = 1):Sprite {
			var sprite:KDrawSprite = new KDrawSprite();
			sprite.draw(source, quality);
			return sprite;
		}

		/**
		 * Draws the source DisplayObject as a bitmap image. Returns it as a BitmapData object.
		 * @param source Source DisplayObject to draw. Ex. Sprite, Shape, etc.
		 * @param quality Rendering quality. The default is 1 (NoAA). 2 means 2x SSAA, super sampling anti-aliasing.
		 * @return A BitmapData object rendered.
		 * @example
		 * <listing version="3.0">
		 * var bitmap:Bitmap = new Bitmap();
		 * addChild(bitmap);
		 * 
		 * var shape:Shape = new Shape();
		 * shape.graphics.beginFill(0xFFCC99);
		 * shape.graphics.drawRect(0, 0, 100, 100);
		 * bitmap.bitmapData = KDrawSprite.getBitmapData(shape);
		 * </listing>
		 */
		public static function getBitmapData(source:DisplayObject, quality:Number = 1):BitmapData {
			var sprite:KDrawSprite = new KDrawSprite(false);
			sprite.draw(source, quality);
			var bmData:BitmapData = sprite.bitmapData;
			sprite.bitmapData = null;
			return bmData;
		}
	}
}
