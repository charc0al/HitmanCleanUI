package hud
{
   import basic.ButtonPromtUtil;
   import common.Animate;
   import common.BaseControl;
   import common.CalcUtil;
   import common.CommonUtils;
   import common.ImageLoader;
   import common.Localization;
   import common.MouseUtil;
   import common.menu.MenuConstants;
   import common.menu.MenuUtils;
   import common.menu.textTicker;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.GesturePhase;
   import flash.events.MouseEvent;
   import flash.events.TransformGestureEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.*;
   import hud.evergreen.EvergreenUtils;
   import menu3.basic.TextTickerUtil;
   import scaleform.gfx.Extensions;
   import scaleform.gfx.TransformGestureEventEx;
   
   public class WeaponSelector extends BaseControl
   {
      
      private static const PX_BLUR:Number = 4;
      
      private static const PX_PERKICONSIZE:Number = 30;
      
      private static const PX_PERKICONGAP:Number = 10;
      
      private static const PX_INVENTORYBGWIDTH:int = MenuConstants.BaseWidth - 47 * 2 - 210 * 2;
      
      private static const PX_INVENTORYBGHEIGHT:int = 210;
      
      private var m_container:Sprite;
      
      private var m_mainCarousel:Sprite;
      
      private var m_background:Sprite;
      
      private var m_perksHolder:Sprite;
      
      private var m_killTypesHolder:Sprite;
      
      private var m_poisonTypesHolder:Sprite;
      
      private var m_weaponInfoHolder:Sprite;
      
      private var m_warningInfoHolder:Sprite;
      
      private var m_ghostItemIndicatorHolder:Sprite;
      
      private var m_evergreenRarityLabel:DisplayObject;
      
      private var m_evergreenLoseOnWoundedLabel:WeaponSelectorKilltypeView;
      
      private var m_view:WeaponSelectorView;
      
      private var m_clickArea:Sprite;
      
      private var m_weaponInfo:WeaponSelectorInfoView;
      
      private var m_actionIllegalWarning:WeaponSelectorWarningView;
      
      private var m_actionIllegalWarningBackDrop:Sprite;
      
      private var m_textTicker:textTicker;
      
      private var m_textTickerUtilDesc:TextTickerUtil = new TextTickerUtil();
      
      private var m_textObj:Object = new Object();
      
      private var m_selectedIndex:int;
      
      private var m_loadingOriginIndex:int;
      
      private var m_previousSelectedIndex:int = -1;
      
      private var m_animDirection:int = 1;
      
      private var m_bgShrinkWidth:int = 0;
      
      private var m_promptsOffsetX:int = 0;
      
      private var m_promptsOffsetY:int = 0;
      
      private const ELLIPSE_WIDTH:Number = 600;
      
      private const ELLIPSE_WIDTH_NARROW:Number = 350;
      
      private const ELLIPSE_HEIGHT:Number = 20;
      
      private const ELLIPSE_DEPTH:Number = 350;
      
      private var m_isInworldUI:Boolean = false;
      
      private var m_useNarrowEllipse:Boolean = false;
      
      private var m_center3DWheel:Boolean = false;
      
      private var m_imageLoadCount:int = 0;
      
      private var m_scaleDownFactor:Number;
      
      private var m_isRotationRunning:Boolean = false;
      
      private var m_currentFrame:int = 0;
      
      private var m_prevFrame:int = 0;
      
      private const ROTATE_SPEED_DEFAULT:Number = 10;
      
      private var m_rotateSpeed:Number = 10;
      
      private var m_isTouchDragActive:Boolean = false;
      
      private var m_isUpdateTouchActive:Boolean = false;
      
      private const TOUCH_ANIMATION_DAMPING:Number = 0.25;
      
      private var m_touchAnimationSpeed:Number = 0;
      
      private var m_touchPos:Point = null;
      
      private var m_touchPosPrev:Point = null;
      
      private var m_itemInfoPosX:Number = 0;
      
      private var m_animIndexStart:Number;
      
      private var m_itemsInView:Number;
      
      private var m_aChildrenPool:Array = new Array();
      
      private var m_aChildrenImageLoaderPool:Array = new Array();
      
      private var m_aChildrenImageLoader2Pool:Array = new Array();
      
      private var m_aWarnings:Array;
      
      private var m_isActionInventory:Boolean;
      
      private var m_initialImageLoaded:Boolean;
      
      private var m_isShowLineWanted:Boolean = false;
      
      private var m_showLine:Boolean = false;
      
      private var m_currentSlotData:Object = null;
      
      private var m_data:Object = null;
      
      private var m_imageRequestMax:int = 5;
      
      private var m_currentImageRequestIndex:int = 0;
      
      private var m_blockImageQueue:Boolean = false;
      
      private var m_poisonViewLethal:WeaponSelectorPoisonTypeView;
      
      private var m_poisonViewSedative:WeaponSelectorPoisonTypeView;
      
      private var m_poisonViewEmetic:WeaponSelectorPoisonTypeView;
      
      private var m_killTypeViews:Vector.<WeaponSelectorKilltypeView> = new Vector.<WeaponSelectorKilltypeView>();
      
      private var m_ghostItemIndicator:WeaponSelectorGhostItemView;
      
      private var m_perkElements:Vector.<WeaponSelectorPerksView> = new Vector.<WeaponSelectorPerksView>();
      
      private var m_perkIcons:Vector.<iconsAll76x76View> = new Vector.<iconsAll76x76View>();
      
      private var m_locNoAvailableItems:String;
      
      private var m_locNoItems:String;
      
      private var m_scaleUp:Boolean = false;
      
      private var m_fontSizeTiny:int = 16;
      
      private var m_fontSizeMedium:int = 18;
      
      private var m_labelOffsetY:int = 61;
      
      private var m_labelFont:String = "$medium";
      
      private var m_imagesThatHaveFilters:Dictionary = new Dictionary(true);
      
      private var m_fScaleAccum:Number = 1;
      
      private var m_scaleToResolution:Number = 1;
      
      private var m_mouseDragEnabled:Boolean = false;
      
      private var m_promptsContainer:Sprite = new Sprite();
      
      private var m_promptObjPrevious:Object = null;
      
      private var m_viewportScaleX:Number = NaN;
      
      public function WeaponSelector()
      {
         super();
         if(ControlsMain.isVrModeActive())
         {
            this.m_scaleUp = true;
            this.m_fontSizeTiny = 20;
            this.m_fontSizeMedium = 22;
            this.m_labelOffsetY = 48;
            this.m_labelFont = MenuConstants.FONT_TYPE_BOLD;
         }
         this.m_selectedIndex = 0;
         this.m_previousSelectedIndex = -1;
         this.m_animIndexStart = 0;
         this.m_itemsInView = 0;
         this.m_background = new Sprite();
         this.m_background.name = "m_background";
         addChild(this.m_background);
         this.m_container = new Sprite();
         this.m_container.name = "m_container";
         addChild(this.m_container);
         this.m_isActionInventory = false;
         this.m_view = new WeaponSelectorView();
         this.m_view.name = "m_view";
         this.m_view.alpha = 0;
         this.m_container.addChild(this.m_view);
         this.m_mainCarousel = new Sprite();
         this.m_mainCarousel.name = "m_mainCarousel";
         this.m_mainCarousel.y = -40;
         this.m_view.addChild(this.m_mainCarousel);
         this.m_weaponInfoHolder = new Sprite();
         this.m_weaponInfoHolder.name = "m_weaponInfoHolder";
         this.m_weaponInfoHolder.y = 16;
         this.m_view.addChild(this.m_weaponInfoHolder);
         this.m_warningInfoHolder = new Sprite();
         this.m_warningInfoHolder.name = "m_warningInfoHolder";
         if(this.m_scaleUp)
         {
            this.m_warningInfoHolder.scaleX = 1.2;
            this.m_warningInfoHolder.scaleY = 1.2;
         }
         this.m_weaponInfoHolder.addChild(this.m_warningInfoHolder);
         this.instantiateWarningMessages();
         this.m_weaponInfo = new WeaponSelectorInfoView();
         this.m_weaponInfo.name = "m_weaponInfo";
         this.m_weaponInfoHolder.addChild(this.m_weaponInfo);
         MenuUtils.setColor(this.m_weaponInfo.line,MenuConstants.COLOR_GREY_ULTRA_LIGHT,false);
         this.m_weaponInfo.line.alpha = 0;
         MenuUtils.setupText(this.m_weaponInfo.label_text,"",50,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorGreyUltraLight);
         MenuUtils.setupText(this.m_weaponInfo.container_label_text,"",24,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorGreyUltraLight);
         MenuUtils.setupText(this.m_weaponInfo.action_text,"",this.m_fontSizeTiny,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
         MenuUtils.setupText(this.m_weaponInfo.desc_text,"",this.m_fontSizeTiny,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
         this.m_weaponInfo.desc_text.visible = false;
         MenuUtils.setupText(this.m_weaponInfo.missing_mc.missing_txt,"",this.m_fontSizeTiny,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorWhite);
         this.m_weaponInfo.missing_mc.missing_txt.autoSize = "left";
         this.m_weaponInfo.missing_mc.visible = false;
         MenuUtils.setupText(this.m_weaponInfo.ammoDisplay.ammoCurrent_txt,"",36,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorGreyUltraLight);
         MenuUtils.setupText(this.m_weaponInfo.ammoDisplay.ammoTotal_txt,"",18,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
         if(this.m_scaleUp)
         {
            this.m_weaponInfo.ammoDisplay.scaleX = 1.2;
            this.m_weaponInfo.ammoDisplay.scaleY = 1.2;
            this.m_weaponInfo.missing_mc.redback_mc.height *= 1.2;
            this.m_weaponInfo.desc_text.height *= 1.2;
         }
         this.reserveAvailableSlots(30);
         MenuUtils.setupText(this.m_view.prompt_txt,"",this.m_fontSizeMedium,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
         this.m_view.prompt_txt.autoSize = "left";
         var _loc1_:int = this.calcInventoryBgWidth();
         var _loc2_:int = this.calcInventoryBgHeight();
         this.m_view.prompt_txt.x = _loc1_ / -2 + 10;
         this.m_view.prompt_txt.y = _loc2_ / 2 - 30;
         this.m_actionIllegalWarning = new WeaponSelectorWarningView();
         this.m_actionIllegalWarning.name = "m_actionIllegalWarning";
         this.m_actionIllegalWarning.visible = false;
         this.m_warningInfoHolder.addChild(this.m_actionIllegalWarning);
         this.m_actionIllegalWarning.y = this.m_labelOffsetY;
         if(this.m_scaleUp)
         {
            this.m_actionIllegalWarning.scaleX = 1.2;
            this.m_actionIllegalWarning.scaleY = 1.2;
         }
         MenuUtils.setupText(this.m_actionIllegalWarning.title,Localization.get("UI_HUD_ACTION_ILLEGAL"),16,this.m_labelFont,MenuConstants.FontColorWhite);
         this.m_actionIllegalWarning.title.autoSize = "left";
         this.m_actionIllegalWarningBackDrop = new Sprite();
         this.m_actionIllegalWarningBackDrop.name = "m_actionIllegalWarningBackDrop";
         this.m_actionIllegalWarningBackDrop.graphics.beginFill(MenuConstants.COLOR_RED,1);
         this.m_actionIllegalWarningBackDrop.graphics.drawRect(0,0,100,21);
         this.m_actionIllegalWarningBackDrop.graphics.endFill();
         this.m_actionIllegalWarning.backDropHolder.addChild(this.m_actionIllegalWarningBackDrop);
         this.m_poisonTypesHolder = new Sprite();
         this.m_poisonTypesHolder.name = "m_poisonTypesHolder";
         if(this.m_scaleUp)
         {
            this.m_poisonTypesHolder.scaleX = 1.2;
            this.m_poisonTypesHolder.scaleY = 1.2;
         }
         this.m_weaponInfo.addChild(this.m_poisonTypesHolder);
         this.m_poisonViewLethal = this.createPoisonType(1,Localization.get("UI_HUD_INVENTORY_POISON_TYPE_LETHAL"));
         this.m_poisonViewSedative = this.createPoisonType(2,Localization.get("UI_HUD_INVENTORY_POISON_TYPE_SEDATIVE"));
         this.m_poisonViewEmetic = this.createPoisonType(3,Localization.get("UI_HUD_INVENTORY_POISON_TYPE_EMETIC"));
         this.m_poisonTypesHolder.addChild(this.m_poisonViewLethal);
         this.m_poisonTypesHolder.addChild(this.m_poisonViewSedative);
         this.m_poisonTypesHolder.addChild(this.m_poisonViewEmetic);
         this.m_killTypesHolder = new Sprite();
         this.m_killTypesHolder.name = "m_killTypesHolder";
         if(this.m_scaleUp)
         {
            this.m_killTypesHolder.scaleX = 1.2;
            this.m_killTypesHolder.scaleY = 1.2;
         }
         this.m_weaponInfo.addChild(this.m_killTypesHolder);
         this.reserveAvailableKillTypes(10);
         this.m_ghostItemIndicator = new WeaponSelectorGhostItemView();
         this.m_ghostItemIndicator.name = "m_ghostItemIndicator";
         MenuUtils.setupText(this.m_ghostItemIndicator.label_txt,Localization.get("UI_HUD_WEAPON_GHOST"),this.m_fontSizeTiny,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraDark);
         this.m_ghostItemIndicator.label_txt.autoSize = "left";
         this.m_ghostItemIndicator.back_mc.width = Math.ceil(this.m_ghostItemIndicator.label_txt.textWidth) + 16;
         this.m_ghostItemIndicator.y = this.m_labelOffsetY;
         this.m_ghostItemIndicator.visible = false;
         this.m_killTypesHolder.addChild(this.m_ghostItemIndicator);
         this.m_perksHolder = new Sprite();
         this.m_perksHolder.name = "m_perksHolder";
         this.m_perksHolder.visible = false;
         this.m_weaponInfo.addChild(this.m_perksHolder);
         this.reservePerks(10);
         this.m_locNoAvailableItems = Localization.get("UI_HUD_INVENTORY_NOAVAILABLEITEMS");
         this.m_locNoItems = Localization.get("UI_HUD_INVENTORY_NOITEMS");
         this.m_imageRequestMax = ControlsMain.isVrModeActive() ? 1 : 5;
         this.m_clickArea = new Sprite();
         addChild(this.m_clickArea);
         addEventListener(TransformGestureEvent.GESTURE_PAN,this.onPan);
         this.m_promptsContainer.name = "promptsContainer";
         this.m_promptsContainer.x = this.xPrompts;
         this.m_promptsContainer.y = this.yPrompts;
         addChild(this.m_promptsContainer);
      }
      
      [PROPERTY(CATEGORY="Weapon Selector",CONSTRAINT="Editors(Spinner) MinValue(0)")]
      public function set BgShrinkWidth(param1:int) : void
      {
         if(this.m_bgShrinkWidth != param1)
         {
            this.m_bgShrinkWidth = param1;
            this.m_container.x = -param1 / 2;
            this.m_promptsContainer.x = this.xPrompts;
            if(!isNaN(this.m_viewportScaleX))
            {
               this.updateBackground();
            }
         }
      }
      
      [PROPERTY(CATEGORY="Weapon Selector")]
      public function set PromptsOffsetX(param1:int) : void
      {
         if(this.m_promptsOffsetX != param1)
         {
            this.m_promptsOffsetX = param1;
            this.m_promptsContainer.x = this.xPrompts;
         }
      }
      
      [PROPERTY(CATEGORY="Weapon Selector")]
      public function set PromptsOffsetY(param1:int) : void
      {
         if(this.m_promptsOffsetY != param1)
         {
            this.m_promptsOffsetY = param1;
            this.m_promptsContainer.y = this.yPrompts;
         }
      }
      
      private function calcInventoryBgWidth() : int
      {
         return PX_INVENTORYBGWIDTH - this.m_bgShrinkWidth;
      }
      
      private function calcInventoryBgHeight() : int
      {
         return PX_INVENTORYBGHEIGHT;
      }
      
      private function get xPrompts() : Number
      {
         return this.m_promptsOffsetX + this.m_view.prompt_txt.x + this.m_bgShrinkWidth / 2;
      }
      
      private function get yPrompts() : Number
      {
         return this.m_promptsOffsetY + this.m_view.prompt_txt.y - 26;
      }
      
      private function get xPerksRight() : Number
      {
         return this.calcInventoryBgWidth() / 2 - 25 + 15;
      }
      
      private function get yPerksMiddle() : Number
      {
         return 72;
      }
      
      public function setupHandling(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         if(this.m_isInworldUI != param1)
         {
            this.m_isInworldUI = param1;
            this.m_useNarrowEllipse = param1;
            this.m_view.prompt_txt.visible = !param1;
            this.m_promptsContainer.visible = !param1;
            this.m_background.visible = !param1;
            if(this.m_isInworldUI)
            {
               MenuUtils.addDropShadowFilter(this.m_weaponInfo.label_text);
            }
            else
            {
               MenuUtils.removeDropShadowFilter(this.m_weaponInfo.label_text);
            }
            this.reservePerks(this.m_perkElements.length,true);
         }
         this.m_center3DWheel = param3;
         this.m_weaponInfoHolder.z = this.m_center3DWheel ? -this.ELLIPSE_DEPTH : 0;
         this.m_background.z = this.m_center3DWheel ? -this.ELLIPSE_DEPTH : 0;
         if(param2 != this.m_mouseDragEnabled)
         {
            this.m_mouseDragEnabled = param2;
            if(this.m_mouseDragEnabled)
            {
               this.m_clickArea.addEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp,false,0,false);
               this.m_clickArea.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown,false,0,false);
            }
            else
            {
               this.m_clickArea.removeEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp,false);
               this.m_clickArea.removeEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown,false);
               removeEventListener(MouseEvent.MOUSE_MOVE,this.handleMouseMove,false);
            }
         }
      }
      
      private function createPoisonType(param1:int, param2:String) : WeaponSelectorPoisonTypeView
      {
         var _loc3_:WeaponSelectorPoisonTypeView = new WeaponSelectorPoisonTypeView();
         var _loc4_:Number = 8;
         MenuUtils.setupText(_loc3_.label_txt,param2,16,this.m_labelFont,MenuConstants.FontColorWhite);
         _loc3_.label_txt.autoSize = "left";
         _loc3_.back_mc.gotoAndStop(param1);
         _loc3_.back_mc.width = Math.ceil(_loc3_.label_txt.textWidth) + 16;
         _loc3_.y = this.m_labelOffsetY;
         _loc3_.visible = false;
         return _loc3_;
      }
      
      private function reserveAvailableKillTypes(param1:int) : void
      {
         var _loc3_:WeaponSelectorKilltypeView = null;
         if(this.m_killTypeViews.length >= param1)
         {
            return;
         }
         var _loc2_:int = int(this.m_killTypeViews.length);
         while(_loc2_ < param1)
         {
            _loc3_ = this.createKillType();
            this.m_killTypesHolder.addChild(_loc3_);
            this.m_killTypeViews.push(_loc3_);
            _loc2_++;
         }
      }
      
      private function createKillType() : WeaponSelectorKilltypeView
      {
         var _loc1_:WeaponSelectorKilltypeView = null;
         var _loc2_:Number = 8;
         _loc1_ = new WeaponSelectorKilltypeView();
         MenuUtils.setupText(_loc1_.label_txt,"",16,this.m_labelFont,MenuConstants.FontColorGreyUltraDark);
         _loc1_.label_txt.autoSize = "left";
         _loc1_.y = this.m_labelOffsetY;
         _loc1_.visible = false;
         return _loc1_;
      }
      
      private function reservePerks(param1:int, param2:Boolean = false) : void
      {
         var _loc4_:WeaponSelectorPerksView = null;
         var _loc5_:iconsAll76x76View = null;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc3_:Number = this.xPerksRight - PX_PERKICONSIZE / 2;
         if(param2)
         {
            _loc7_ = 0;
            while(_loc7_ < this.m_perkIcons.length)
            {
               _loc8_ = (PX_PERKICONSIZE + PX_PERKICONGAP) * _loc7_;
               this.m_perkElements[_loc7_].x = _loc3_ - _loc8_;
               _loc7_++;
            }
         }
         if(this.m_perkIcons.length >= param1)
         {
            return;
         }
         var _loc6_:int = int(this.m_perkIcons.length);
         while(_loc6_ < param1)
         {
            _loc4_ = new WeaponSelectorPerksView();
            _loc4_.visible = false;
            _loc5_ = new iconsAll76x76View();
            _loc4_.perks.addChild(_loc5_);
            _loc4_.width = _loc4_.height = PX_PERKICONSIZE;
            _loc9_ = (PX_PERKICONSIZE + PX_PERKICONGAP) * _loc6_;
            _loc4_.x = _loc3_ - _loc9_;
            _loc4_.y = this.yPerksMiddle;
            this.m_perksHolder.addChild(_loc4_);
            this.m_perkElements.push(_loc4_);
            this.m_perkIcons.push(_loc5_);
            _loc6_++;
         }
      }
      
      private function reserveAvailableSlots(param1:int) : void
      {
         var _loc3_:WeaponSlotView = null;
         var _loc4_:ImageLoader = null;
         var _loc5_:ImageLoader = null;
         if(this.m_aChildrenPool.length >= param1)
         {
            return;
         }
         var _loc2_:int = int(this.m_aChildrenPool.length);
         while(_loc2_ < param1)
         {
            _loc3_ = new WeaponSlotView();
            this.m_mainCarousel.addChild(_loc3_);
            _loc4_ = new ImageLoader();
            _loc3_.weaponImage_mc.addChild(_loc4_);
            this.m_aChildrenImageLoaderPool.push(_loc4_);
            MenuUtils.setColor(_loc3_.weaponImage_mc,MenuConstants.COLOR_GREY_ULTRA_LIGHT,false);
            _loc5_ = new ImageLoader();
            _loc3_.containedWeaponImage_mc.addChild(_loc5_);
            this.m_aChildrenImageLoader2Pool.push(_loc5_);
            this.m_aChildrenPool.push(_loc3_);
            _loc2_++;
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc3_:ImageLoader = null;
         var _loc4_:ImageLoader = null;
         var _loc5_:WeaponSlotView = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         this.m_blockImageQueue = true;
         this.m_data = param1;
         this.m_currentSlotData = null;
         this.m_previousSelectedIndex = -1;
         this.m_currentImageRequestIndex = 0;
         this.m_view.alpha = 0;
         Animate.to(this.m_view,0.05,0.2,{"alpha":1},Animate.Linear);
         this.m_isActionInventory = param1.isActionInventory;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_itemsInView)
         {
            _loc3_ = this.m_aChildrenImageLoaderPool[_loc2_];
            _loc3_.cancel();
            _loc4_ = this.m_aChildrenImageLoader2Pool[_loc2_];
            _loc4_.cancel();
            _loc5_ = this.m_aChildrenPool[_loc2_];
            _loc5_.visible = false;
            _loc2_++;
         }
         this.m_itemsInView = param1.mainslotsSlim.length;
         this.reserveAvailableSlots(this.m_itemsInView);
         this.m_scaleDownFactor = NaN;
         if(this.m_itemsInView == 0)
         {
            this.m_mainCarousel.visible = false;
            this.m_warningInfoHolder.visible = false;
            this.m_view.prompt_txt.htmlText = "";
            _loc6_ = "";
            if(param1.noItemsMessage)
            {
               _loc6_ = Localization.get(param1.noItemsMessage);
            }
            else
            {
               _loc6_ = param1.otherslotsCount > 0 ? this.m_locNoAvailableItems : this.m_locNoItems;
            }
            MenuUtils.setupText(this.m_view.action_txt,_loc6_,40,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorGreyMedium);
            this.m_view.action_txt.visible = true;
            this.m_weaponInfo.visible = false;
         }
         else
         {
            this.m_mainCarousel.visible = true;
            this.m_warningInfoHolder.visible = true;
            this.m_view.action_txt.visible = false;
            this.m_weaponInfo.visible = true;
            this.m_imageLoadCount = 0;
            this.m_initialImageLoaded = false;
            this.m_selectedIndex = param1.selectedIndex;
            if(this.m_selectedIndex == -1)
            {
               this.m_selectedIndex = 0;
            }
            this.m_loadingOriginIndex = this.m_selectedIndex;
            this.m_animIndexStart = this.m_selectedIndex;
            this.m_blockImageQueue = false;
            _loc7_ = 0;
            while(_loc7_ < this.m_imageRequestMax)
            {
               this.loadImageFromQueue();
               _loc7_++;
            }
            this.setSelectedImage(true);
         }
      }
      
      private function loadImageFromQueue() : void
      {
         if(this.m_blockImageQueue || this.m_currentImageRequestIndex >= this.m_itemsInView)
         {
            return;
         }
         var _loc1_:int = (this.m_currentImageRequestIndex + 1) / 2;
         var _loc2_:int = this.m_currentImageRequestIndex % 2 == 0 ? this.m_loadingOriginIndex + _loc1_ : this.m_loadingOriginIndex - _loc1_;
         _loc2_ = (_loc2_ + this.m_itemsInView) % this.m_itemsInView;
         ++this.m_currentImageRequestIndex;
         this.loadWeaponImage(_loc2_);
         this.loadContainedWeaponImage(_loc2_);
      }
      
      public function Rotate(param1:int, param2:int) : void
      {
         this.m_selectedIndex = param1;
         this.setSelectedImage();
         this.RotateInternal(param1,param2,this.ROTATE_SPEED_DEFAULT);
      }
      
      private function RotateInternal(param1:int, param2:int, param3:Number) : void
      {
         this.m_selectedIndex = param1;
         if(this.m_itemsInView <= 1)
         {
            this.m_animIndexStart = this.m_selectedIndex;
         }
         this.m_animDirection = param2 > 0 ? 1 : -1;
         if(!this.m_isRotationRunning)
         {
            addEventListener(Event.ENTER_FRAME,this.onUpdateFrame);
            this.m_isRotationRunning = true;
            this.m_currentFrame = getTimer();
            this.m_prevFrame = this.m_currentFrame;
         }
         this.m_rotateSpeed = param3;
      }
      
      public function UpdateSelectedSlot(param1:Object, param2:int) : void
      {
         var _loc3_:Object = param1.slotData;
         if(_loc3_ != null)
         {
            this.m_currentSlotData = _loc3_;
            this.updateItemInformationWithSlotData(_loc3_,param2);
         }
         this.updatePrompt(param1);
      }
      
      public function UpdateAmmoDisplayPosition(param1:int) : void
      {
         this.m_weaponInfo.ammoDisplay.x = (120 - this.m_aChildrenPool[param1].weaponImage_mc.getChildAt(0).width) / 2 - 120 - (this.m_weaponInfo.ammoDisplay.ammoTotal_txt.x + this.m_weaponInfo.ammoDisplay.ammoTotal_txt.textWidth) - 22;
         if(this.m_scaleUp)
         {
            this.m_weaponInfo.ammoDisplay.x -= 20;
         }
      }
      
      private function updateItemInformationWithSlotData(param1:Object, param2:int) : void
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:WeaponSelectorGhostItemParticleView = null;
         if(param1.nItemHUDType == 1 && !this.m_initialImageLoaded)
         {
            return;
         }
         this.m_textTickerUtilDesc.onUnregister();
         this.m_textObj = [];
         this.m_weaponInfo.label_text.htmlText = "";
         this.m_weaponInfo.action_text.htmlText = "";
         this.m_weaponInfo.container_label_text.htmlText = "";
         this.m_weaponInfo.missing_mc.visible = false;
         this.m_weaponInfo.desc_text.visible = false;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_killTypeViews.length)
         {
            this.m_killTypeViews[_loc9_].visible = false;
            _loc3_++;
         }
         this.m_ghostItemIndicator.visible = false;
         this.m_actionIllegalWarning.visible = false;
         MenuUtils.setColor(this.m_weaponInfo.line,param1.notininventory ? uint(MenuConstants.COLOR_GREY_MEDIUM) : uint(MenuConstants.COLOR_GREY_ULTRA_LIGHT),false);
         this.m_isShowLineWanted = false;
         if(this.m_isActionInventory)
         {
            if(this.m_textTicker)
            {
               this.m_textTicker.stopTextTicker(this.m_weaponInfo.label_text,param1.label);
            }
            _loc4_ = MenuConstants.FontColorGreyUltraLight;
            _loc5_ = MenuConstants.COLOR_GREY_ULTRA_LIGHT;
            if(this.m_actionIllegalWarning)
            {
               this.m_warningInfoHolder.removeChild(this.m_actionIllegalWarning);
            }
            this.m_poisonTypesHolder.visible = false;
            if(!param1.notininventory && Boolean(param1.isIllegal))
            {
               this.m_isShowLineWanted = true;
               _loc6_ = 8;
               _loc7_ = 21 + this.m_actionIllegalWarning.title.textWidth + 7;
               this.m_warningInfoHolder.alpha = 1;
               this.m_warningInfoHolder.addChild(this.m_actionIllegalWarning);
               this.m_actionIllegalWarning.visible = true;
               this.m_actionIllegalWarningBackDrop.scaleX = _loc7_ / 100;
               _loc8_ = _loc7_ + _loc6_;
               if(param1.sPoisonType != undefined)
               {
                  this.setupPoisonType(param1.sPoisonType,_loc8_);
               }
            }
            if(param1.notininventory)
            {
               this.m_weaponInfo.missing_mc.missing_txt.htmlText = param1.missingText;
               this.m_weaponInfo.missing_mc.redback_mc.width = Math.ceil(this.m_weaponInfo.missing_mc.missing_txt.textWidth) + 16;
               this.m_weaponInfo.missing_mc.visible = true;
               this.m_weaponInfo.desc_text.width = 650 - (this.m_weaponInfo.missing_mc.redback_mc.width + 10);
               this.m_weaponInfo.desc_text.x = this.m_weaponInfo.missing_mc.redback_mc.width + 10;
               this.m_weaponInfo.desc_text.htmlText = param1.longDescription ? param1.longDescription : "";
               if(MenuUtils.truncateTextfield(this.m_weaponInfo.desc_text,1,MenuConstants.FontColorGreyUltraLight))
               {
                  this.m_textTickerUtilDesc.addTextTickerHtml(this.m_weaponInfo.desc_text);
                  this.m_textTickerUtilDesc.callTextTicker(true);
               }
               this.m_weaponInfo.desc_text.visible = true;
               this.m_isShowLineWanted = true;
               _loc4_ = MenuConstants.FontColorGreyMedium;
               _loc5_ = MenuConstants.COLOR_GREY_MEDIUM;
            }
            var actionName:String = param1.actionName != null ? String(param1.actionName) : "";
            if(actionName.length > 0)
            {
               var c:String = actionName.charAt(0);
               if(c == "$" || c == "-" || c == "_" || c == "^" || c == "+" || c == "=" || c == "." || c == ",")
               {
                  actionName = actionName.substr(1);
               }
            }
            this.m_weaponInfo.action_text.htmlText = actionName;
            MenuUtils.setTextColor(this.m_weaponInfo.action_text,_loc5_);
            this.m_textObj.title = param1.label;
            this.m_textObj.tf = this.m_weaponInfo.label_text;
            this.m_weaponInfo.label_text.htmlText = param1.label;
            MenuUtils.setTextColor(this.m_weaponInfo.label_text,_loc5_);
            if(MenuUtils.truncateTextfield(this.m_weaponInfo.label_text,1,_loc4_))
            {
               if(!this.m_textTicker)
               {
                  this.m_textTicker = new textTicker();
               }
               this.m_textTicker.startTextTicker(this.m_weaponInfo.label_text,param1.label,CommonUtils.changeFontToGlobalIfNeeded);
               this.m_textTicker.setTextColor(_loc5_);
            }
         }
         else
         {
            MenuUtils.setTextColor(this.m_weaponInfo.label_text,MenuConstants.COLOR_GREY_ULTRA_LIGHT);
            if(this.m_textTicker)
            {
               this.m_textTicker.stopTextTicker(this.m_weaponInfo.label_text,param1.label);
            }
            this.m_poisonTypesHolder.visible = false;
            if(Boolean(param1.isContainer) && Boolean(param1.containsItem))
            {
               this.m_textObj.title = param1.containedLabel;
               this.m_textObj.tf = this.m_weaponInfo.label_text;
               this.m_weaponInfo.label_text.htmlText = param1.containedLabel;
               if(MenuUtils.truncateTextfield(this.m_weaponInfo.label_text,1,MenuConstants.FontColorGreyUltraLight))
               {
                  if(!this.m_textTicker)
                  {
                     this.m_textTicker = new textTicker();
                  }
                  this.m_textTicker.startTextTicker(this.m_weaponInfo.label_text,param1.containedLabel,CommonUtils.changeFontToGlobalIfNeeded);
                  this.m_textTicker.setTextColor(MenuConstants.COLOR_GREY_ULTRA_LIGHT);
               }
               this.m_weaponInfo.container_label_text.htmlText = param1.label;
               if(param1.bContainedItemSuspicious)
               {
                  this.m_isShowLineWanted = true;
                  this.showWarningMessage(0,false);
                  this.showWarningMessage(1,true);
               }
               else if(param1.bContainedItemIllegal)
               {
                  this.m_isShowLineWanted = true;
                  this.showWarningMessage(0,true);
                  this.showWarningMessage(1,false);
                  if(param1.bContainedItemDetectedDuringFrisk)
                  {
                     this.showWarningMessage(2,false);
                  }
                  else
                  {
                     this.showWarningMessage(2,true);
                  }
               }
               else
               {
                  this.showWarningMessage(0,false);
                  this.showWarningMessage(1,false);
                  this.showWarningMessage(2,false);
               }
            }
            else
            {
               this.m_textObj.title = param1.label;
               this.m_textObj.tf = this.m_weaponInfo.label_text;
               this.m_weaponInfo.label_text.htmlText = param1.label;
               if(MenuUtils.truncateTextfield(this.m_weaponInfo.label_text,1,MenuConstants.FontColorGreyUltraLight))
               {
                  if(!this.m_textTicker)
                  {
                     this.m_textTicker = new textTicker();
                  }
                  this.m_textTicker.startTextTicker(this.m_weaponInfo.label_text,param1.label,CommonUtils.changeFontToGlobalIfNeeded);
                  this.m_textTicker.setTextColor(MenuConstants.COLOR_GREY_ULTRA_LIGHT);
               }
               if(param1.suspicious)
               {
                  this.m_isShowLineWanted = true;
                  this.showWarningMessage(0,false);
                  this.showWarningMessage(1,true);
               }
               else if(param1.illegal)
               {
                  this.m_isShowLineWanted = true;
                  this.showWarningMessage(0,true);
                  this.showWarningMessage(1,false);
                  if(param1.detectedDuringFrisk)
                  {
                     this.showWarningMessage(2,false);
                  }
                  else
                  {
                     this.showWarningMessage(2,true);
                  }
               }
               else
               {
                  this.showWarningMessage(0,false);
                  this.showWarningMessage(1,false);
                  this.showWarningMessage(2,false);
               }
               this.hideKillTypes();
               if(param1.actionAndKillTypes != undefined || param1.nItemHUDType == 1)
               {
                  if(param1.actionAndKillTypes.length > 0 || param1.nItemHUDType == 1)
                  {
                     this.m_isShowLineWanted = true;
                     this.setupKillTypes(param1.actionAndKillTypes,param1.nItemHUDType == 1 ? true : false);
                  }
               }
               if(param1.sPoisonType != undefined)
               {
                  this.m_itemInfoPosX = this.setupPoisonType(param1.sPoisonType,this.m_itemInfoPosX);
               }
               if(this.m_ghostItemIndicatorHolder != null)
               {
                  _loc9_ = 0;
                  while(_loc9_ < this.m_ghostItemIndicatorHolder.numChildren - 1)
                  {
                     this.loopGhostItemIndicators(this.m_ghostItemIndicatorHolder.getChildAt(_loc9_),false);
                     _loc9_++;
                  }
                  this.m_weaponInfo.removeChild(this.m_ghostItemIndicatorHolder);
               }
               if(param1.nItemHUDType == 1)
               {
                  _loc10_ = this.m_aChildrenPool[param2];
                  this.m_ghostItemIndicatorHolder = new Sprite();
                  this.m_ghostItemIndicatorHolder.name = "m_ghostItemIndicatorHolder";
                  this.m_weaponInfo.addChild(this.m_ghostItemIndicatorHolder);
                  _loc11_ = 120 - _loc10_.weaponImage_mc.width;
                  _loc12_ = 190 - _loc10_.weaponImage_mc.height;
                  _loc13_ = 0;
                  while(_loc13_ < 5)
                  {
                     _loc14_ = new WeaponSelectorGhostItemParticleView();
                     _loc14_.x = _loc11_ / 2 - 137 + _loc10_.weaponImage_mc.width / 2;
                     _loc14_.y = _loc10_.weaponImage_mc.height / -2 - 10 + _loc12_ / 2 + _loc10_.weaponImage_mc.height / 2;
                     this.m_ghostItemIndicatorHolder.addChild(_loc14_);
                     this.loopGhostItemIndicators(_loc14_,true,_loc10_.weaponImage_mc.height / 4);
                     _loc13_++;
                  }
               }
            }
         }
         if(param1.notininventory)
         {
            this.m_weaponInfo.ammoDisplay.ammoCurrent_txt.htmlText = "";
            this.m_weaponInfo.ammoDisplay.ammoTotal_txt.htmlText = "";
         }
         else if(param1.nAmmoTotal >= 0 && param1.nAmmoRemaining >= 0)
         {
            this.m_weaponInfo.ammoDisplay.ammoCurrent_txt.htmlText = param1.nAmmoRemaining;
            if(param1.canReload)
            {
               this.m_weaponInfo.ammoDisplay.ammoTotal_txt.htmlText = "/" + param1.nAmmoTotal;
            }
            else
            {
               this.m_weaponInfo.ammoDisplay.ammoTotal_txt.htmlText = "";
            }
         }
         else if(param1.ammo > -1)
         {
            this.m_weaponInfo.ammoDisplay.ammoCurrent_txt.htmlText = param1.ammo;
            this.m_weaponInfo.ammoDisplay.ammoTotal_txt.htmlText = "";
         }
         else if(param1.count > 1 && param1.ammo == -1)
         {
            this.m_weaponInfo.ammoDisplay.ammoCurrent_txt.htmlText = "x" + param1.count;
            this.m_weaponInfo.ammoDisplay.ammoTotal_txt.htmlText = "";
         }
         else
         {
            this.m_weaponInfo.ammoDisplay.ammoCurrent_txt.htmlText = "";
            this.m_weaponInfo.ammoDisplay.ammoTotal_txt.htmlText = "";
         }
         this.m_weaponInfo.ammoDisplay.ammoTotal_txt.x = this.m_weaponInfo.ammoDisplay.ammoCurrent_txt.textWidth + 2;
         this.UpdateAmmoDisplayPosition(param2);
         if(this.m_evergreenRarityLabel != null)
         {
            this.m_weaponInfo.removeChild(this.m_evergreenRarityLabel);
            this.m_evergreenRarityLabel = null;
            this.m_perksHolder.x = 0;
         }
         if(EvergreenUtils.isValidRarityLabel(param1.evergreenRarity))
         {
            this.m_evergreenRarityLabel = EvergreenUtils.createRarityLabel(param1.evergreenRarity,false);
            this.m_evergreenRarityLabel.name = "m_evergreenRarityLabel";
            this.m_evergreenRarityLabel.height = PX_PERKICONSIZE;
            this.m_evergreenRarityLabel.scaleX = this.m_evergreenRarityLabel.scaleY;
            this.m_evergreenRarityLabel.x = this.xPerksRight - this.m_evergreenRarityLabel.width / 2;
            this.m_evergreenRarityLabel.y = this.yPerksMiddle;
            this.m_weaponInfo.addChild(this.m_evergreenRarityLabel);
            this.m_perksHolder.x = -(this.m_evergreenRarityLabel.width + PX_PERKICONGAP);
            this.m_isShowLineWanted = true;
         }
         if(this.m_evergreenLoseOnWoundedLabel != null && !param1.evergreenLoseOnWounded)
         {
            this.m_killTypesHolder.removeChild(this.m_evergreenLoseOnWoundedLabel);
            this.m_evergreenLoseOnWoundedLabel = null;
         }
         if(param1.evergreenLoseOnWounded === true)
         {
            if(this.m_evergreenLoseOnWoundedLabel == null)
            {
               this.m_evergreenLoseOnWoundedLabel = new WeaponSelectorKilltypeView();
               this.m_evergreenLoseOnWoundedLabel.name = "m_evergreenLoseOnWoundedLabel";
               this.m_evergreenLoseOnWoundedLabel.label_txt.htmlText = Localization.get("UI_INVENTORY_EVERGREEN_LOSE_ON_WOUNDED");
               this.m_evergreenLoseOnWoundedLabel.back_mc.width = Math.ceil(this.m_evergreenLoseOnWoundedLabel.label_txt.textWidth) + 16;
               this.m_killTypesHolder.addChild(this.m_evergreenLoseOnWoundedLabel);
            }
            this.m_evergreenLoseOnWoundedLabel.x = this.m_itemInfoPosX;
            this.m_itemInfoPosX += this.m_evergreenLoseOnWoundedLabel.width + 8;
            this.m_evergreenLoseOnWoundedLabel.y = this.m_labelOffsetY;
            this.m_isShowLineWanted = true;
         }
         this.m_perksHolder.visible = false;
         if(param1.perks != undefined && param1.perks.length > 0)
         {
            this.setupPerks(param1.perks);
            this.m_perksHolder.visible = true;
            this.m_isShowLineWanted = true;
         }
         this.showLine(this.m_isShowLineWanted);
      }
      
      private function loopGhostItemIndicators(param1:DisplayObject, param2:Boolean, param3:Number = 0) : void
      {
         var _loc4_:Number = NaN;
         Animate.kill(param1);
         if(param2)
         {
            if(Math.random() > 0.5)
            {
               param1.rotation = MenuUtils.getRandomInRange(-60,-120);
            }
            else
            {
               param1.rotation = MenuUtils.getRandomInRange(60,120);
            }
            _loc4_ = param1.y;
            param1.y = _loc4_ + MenuUtils.getRandomInRange(-param3,param3);
            this.loopStart({
               "obj":param1,
               "yRange":param3,
               "orignalYPos":_loc4_
            });
         }
      }
      
      private function loopStart(param1:Object) : void
      {
         Animate.fromTo(param1.obj,MenuUtils.getRandomInRange(3,7) / 10,MenuUtils.getRandomInRange(0,5) / 10,{"frames":1},{"frames":28},Animate.Linear,this.loopEnd,param1);
      }
      
      private function loopEnd(param1:Object) : void
      {
         if(Math.random() > 0.5)
         {
            param1.obj.rotation = MenuUtils.getRandomInRange(-60,-120);
         }
         else
         {
            param1.obj.rotation = MenuUtils.getRandomInRange(60,120);
         }
         param1.obj.y = param1.orignalYPos + MenuUtils.getRandomInRange(-param1.yRange,param1.yRange);
         this.loopStart(param1);
      }
      
      private function showLine(param1:Boolean, param2:Boolean = false) : void
      {
         if(this.m_isInworldUI && !this.m_evergreenRarityLabel && !this.m_perksHolder.visible)
         {
            param1 = false;
         }
         if(this.m_showLine == param1)
         {
            return;
         }
         this.m_showLine = param1;
         if(param2)
         {
            Animate.kill(this.m_weaponInfo.line);
            this.m_weaponInfo.line.alpha = param1 ? 1 : 0;
         }
         else
         {
            Animate.to(this.m_weaponInfo.line,0.2,0,{"alpha":(param1 ? 1 : 0)},Animate.ExpoOut);
         }
      }
      
      private function setupPoisonType(param1:String, param2:Number) : Number
      {
         this.m_poisonViewLethal.visible = false;
         this.m_poisonViewSedative.visible = false;
         this.m_poisonViewEmetic.visible = false;
         var _loc3_:WeaponSelectorPoisonTypeView = null;
         switch(param1)
         {
            case "POISONTYPE_LETHAL":
               _loc3_ = this.m_poisonViewLethal;
               break;
            case "POISONTYPE_SEDATIVE":
               _loc3_ = this.m_poisonViewSedative;
               break;
            case "POISONTYPE_EMETIC":
               _loc3_ = this.m_poisonViewEmetic;
         }
         if(_loc3_ == null)
         {
            return param2;
         }
         this.m_isShowLineWanted = true;
         var _loc4_:Number = 8;
         _loc3_.x = param2;
         param2 += _loc3_.back_mc.width + _loc4_;
         this.m_poisonTypesHolder.visible = true;
         _loc3_.visible = true;
         return param2;
      }
      
      private function hideKillTypes() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_killTypeViews.length)
         {
            this.m_killTypeViews[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      private function setupKillTypes(param1:Array, param2:Boolean) : void
      {
         var _loc3_:WeaponSelectorKilltypeView = null;
         var _loc6_:Number = NaN;
         var _loc4_:Number = 8;
         this.reserveAvailableKillTypes(param1.length);
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc3_ = this.m_killTypeViews[_loc5_];
            _loc3_.label_txt.htmlText = param1[_loc5_];
            _loc6_ = Math.ceil(_loc3_.label_txt.textWidth) + 16;
            _loc3_.back_mc.width = _loc6_;
            _loc3_.x = this.m_itemInfoPosX;
            this.m_itemInfoPosX += _loc6_ + _loc4_;
            _loc3_.visible = true;
            _loc5_++;
         }
         if(param2)
         {
            this.m_ghostItemIndicator.visible = true;
            this.m_ghostItemIndicator.x = this.m_itemInfoPosX;
            this.m_itemInfoPosX += this.m_ghostItemIndicator.back_mc.width + _loc4_;
         }
      }
      
      private function instantiateWarningMessages() : void
      {
         var _loc3_:WeaponSelectorWarningView = null;
         var _loc4_:Sprite = null;
         this.m_warningInfoHolder.alpha = 1;
         var _loc1_:Array = new Array(Localization.get("UI_HUD_WEAPON_ILLEGAL"),Localization.get("UI_HUD_WEAPON_SUSPISIOUS"),Localization.get("UI_HUD_INVENTORY_NOT_DETECTED_DURING_FRISK"));
         this.m_aWarnings = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = new WeaponSelectorWarningView();
            this.m_warningInfoHolder.addChild(_loc3_);
            _loc3_.gotoAndStop(_loc2_ + 1);
            _loc3_.title.x = _loc2_ == 2 ? 5 : 18;
            MenuUtils.setupText(_loc3_.title,_loc1_[_loc2_],16,this.m_labelFont,_loc2_ == 2 ? MenuConstants.FontColorGreyUltraDark : MenuConstants.FontColorWhite);
            _loc3_.title.autoSize = "left";
            _loc4_ = new Sprite();
            _loc4_.graphics.beginFill(_loc2_ == 2 ? uint(MenuConstants.COLOR_WHITE) : uint(MenuConstants.COLOR_RED),1);
            _loc4_.graphics.drawRect(0,0,_loc2_ == 2 ? 7 + _loc3_.title.textWidth + 7 : 21 + _loc3_.title.textWidth + 7,21);
            _loc4_.graphics.endFill();
            _loc3_.backDropHolder.addChild(_loc4_);
            _loc3_.alpha = 0;
            _loc3_.y = this.m_labelOffsetY;
            this.m_aWarnings.push(_loc3_);
            _loc2_++;
         }
      }
      
      public function showWarningMessage(param1:int, param2:Boolean) : void
      {
         this.m_warningInfoHolder.alpha = 1;
         if(param1 == 0)
         {
            this.m_itemInfoPosX = 0;
         }
         this.m_aWarnings[param1].x = this.m_itemInfoPosX;
         if(param2)
         {
            this.m_itemInfoPosX += this.m_aWarnings[param1].backDropHolder.getChildAt(0).width + 8;
         }
         var _loc3_:Number = param2 ? 1 : 0;
         if(this.m_aWarnings[param1].alpha != _loc3_)
         {
            Animate.to(this.m_aWarnings[param1],0.2,0,{"alpha":_loc3_},Animate.ExpoOut);
         }
         else
         {
            Animate.kill(this.m_aWarnings[param1]);
         }
      }
      
      private function setupPerks(param1:Array) : void
      {
         this.reservePerks(param1.length);
         var _loc2_:int = 0;
         while(_loc2_ < this.m_perkElements.length)
         {
            if(_loc2_ < param1.length)
            {
               MenuUtils.setupIcon(this.m_perkIcons[_loc2_],param1[_loc2_],MenuConstants.COLOR_GREY_ULTRA_DARK,false,false);
               this.m_perkElements[_loc2_].visible = true;
            }
            else
            {
               this.m_perkElements[_loc2_].visible = false;
            }
            _loc2_++;
         }
      }
      
      public function UpdatePositions() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_itemsInView)
         {
            if(this.m_aChildrenPool[_loc1_].visible)
            {
               this.UpdatePosition(_loc1_);
            }
            _loc1_++;
         }
      }
      
      private function calcScaleDownFactor() : void
      {
         var _loc1_:int = 8;
         var _loc2_:int = 16;
         var _loc3_:Number = 0.6;
         this.m_scaleDownFactor = 1;
         if(this.m_itemsInView > _loc1_)
         {
            this.m_scaleDownFactor = 1 - (1 - _loc3_) * (this.m_itemsInView - _loc1_) / (_loc2_ - _loc1_);
            if(this.m_scaleDownFactor < _loc3_)
            {
               this.m_scaleDownFactor = _loc3_;
            }
         }
      }
      
      private function UpdatePosition(param1:int) : void
      {
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc2_:Number = Math.PI * 2;
         var _loc3_:Number = -110;
         var _loc4_:Boolean = ControlsMain.isVrModeActive();
         var _loc5_:Number = this.m_useNarrowEllipse ? this.ELLIPSE_WIDTH_NARROW : this.ELLIPSE_WIDTH;
         var _loc6_:Number = Math.acos(_loc3_ / _loc5_);
         var _loc7_:Number = this.ELLIPSE_HEIGHT * 3;
         var _loc8_:Number = this.ELLIPSE_HEIGHT * 2;
         if(isNaN(this.m_scaleDownFactor))
         {
            this.calcScaleDownFactor();
         }
         _loc9_ = Number((param1 - this.m_animIndexStart + this.m_itemsInView) % this.m_itemsInView) / this.m_itemsInView;
         var _loc10_:Number = _loc2_ * _loc9_ + _loc6_;
         if(this.m_bgShrinkWidth == 0)
         {
            _loc11_ = _loc5_;
         }
         else if(_loc9_ >= 0.75)
         {
            _loc11_ = _loc5_;
         }
         else if(_loc9_ <= 0.25)
         {
            _loc11_ = CalcUtil.mapRangeUnchecked(_loc9_,0,0.25,_loc5_,_loc5_ - this.m_bgShrinkWidth);
         }
         else
         {
            _loc11_ = CalcUtil.mapRangeUnchecked(_loc9_,0.25,0.75,_loc5_ - this.m_bgShrinkWidth,_loc5_);
         }
         var _loc12_:Number = Math.cos(_loc10_) * _loc11_;
         var _loc13_:Number = Math.sin(_loc10_) * this.ELLIPSE_HEIGHT;
         var _loc14_:Number = this.m_center3DWheel ? 0 : this.ELLIPSE_DEPTH;
         var _loc15_:Number = Math.sin(_loc6_) * -this.ELLIPSE_DEPTH + this.ELLIPSE_DEPTH;
         var _loc16_:Number = Math.sin(_loc10_) * -this.ELLIPSE_DEPTH + _loc14_;
         var _loc17_:Number = Number(_loc7_ / _loc8_ * 0.09 + 0.3);
         var _loc18_:Number = Number((this.ELLIPSE_HEIGHT * 3 + _loc7_) / _loc8_ * 0.09 + 0.3);
         var _loc19_:Number = Number((_loc13_ * 3 + _loc7_) / _loc8_ * 0.09 + 0.3);
         if(param1 == this.m_selectedIndex)
         {
            _loc20_ = _loc19_ * 1.75;
            this.m_mainCarousel.swapChildrenAt(this.m_mainCarousel.numChildren - 1,this.m_mainCarousel.getChildIndex(this.m_aChildrenPool[param1]));
            this.m_aChildrenPool[param1].x = _loc12_;
            this.m_aChildrenPool[param1].y = _loc13_;
            if(_loc4_)
            {
               this.m_aChildrenPool[param1].scaleX = _loc18_ * 1.75;
               this.m_aChildrenPool[param1].scaleY = _loc18_ * 1.75;
               this.m_aChildrenPool[param1].z = _loc16_ - _loc15_;
            }
            else
            {
               this.m_aChildrenPool[param1].scaleX = this.m_aChildrenPool[param1].scaleY = _loc19_ * 1.75;
            }
            this.m_aChildrenPool[param1].alpha = _loc20_;
         }
         else
         {
            _loc20_ = this.m_isActionInventory ? _loc19_ * _loc19_ + 0.4 : _loc19_ * _loc19_ + 0.1;
            this.m_aChildrenPool[param1].x = _loc12_;
            this.m_aChildrenPool[param1].y = _loc13_;
            if(_loc4_)
            {
               this.m_aChildrenPool[param1].scaleX = _loc18_ * this.m_scaleDownFactor;
               this.m_aChildrenPool[param1].scaleY = _loc18_ * this.m_scaleDownFactor;
               this.m_aChildrenPool[param1].z = _loc16_;
            }
            else
            {
               this.m_aChildrenPool[param1].scaleX = this.m_aChildrenPool[param1].scaleY = _loc19_ * this.m_scaleDownFactor;
            }
            this.m_aChildrenPool[param1].alpha = _loc20_;
         }
      }
      
      private function setSelectedImage(param1:Boolean = false) : void
      {
         if(this.m_previousSelectedIndex == this.m_selectedIndex)
         {
            return;
         }
         var _loc2_:* = this.m_data.mainslotsSlim[this.m_selectedIndex].isContainer === true;
         var _loc3_:Number = 1.75;
         var _loc4_:Number = _loc2_ ? 0 : 25;
         if(this.m_previousSelectedIndex >= 0 && this.m_previousSelectedIndex < this.m_itemsInView)
         {
            if(param1)
            {
               Animate.kill(this.m_aChildrenPool[this.m_previousSelectedIndex].weaponImage_mc);
               Animate.kill(this.m_aChildrenPool[this.m_previousSelectedIndex].containedWeaponImage_mc);
               this.m_aChildrenPool[this.m_previousSelectedIndex].weaponImage_mc.y = 0;
               this.m_aChildrenPool[this.m_previousSelectedIndex].containedWeaponImage_mc.y = 0;
            }
            else
            {
               Animate.to(this.m_aChildrenPool[this.m_previousSelectedIndex].weaponImage_mc,0.2,0,{"y":0},Animate.SineOut);
               Animate.to(this.m_aChildrenPool[this.m_previousSelectedIndex].containedWeaponImage_mc,0.2,0,{"y":0},Animate.SineOut);
            }
         }
         if(this.m_selectedIndex >= 0 && this.m_selectedIndex < this.m_itemsInView)
         {
            if(param1)
            {
               Animate.kill(this.m_aChildrenPool[this.m_selectedIndex].weaponImage_mc);
               Animate.kill(this.m_aChildrenPool[this.m_selectedIndex].containedWeaponImage_mc);
               this.m_aChildrenPool[this.m_selectedIndex].weaponImage_mc.y = _loc4_;
               this.m_aChildrenPool[this.m_selectedIndex].containedWeaponImage_mc.y = _loc4_;
            }
            else
            {
               Animate.to(this.m_aChildrenPool[this.m_selectedIndex].weaponImage_mc,0.2,0,{"y":_loc4_},Animate.SineOut);
               Animate.to(this.m_aChildrenPool[this.m_selectedIndex].containedWeaponImage_mc,0.2,0,{"y":_loc4_},Animate.SineOut);
            }
         }
         this.m_previousSelectedIndex = this.m_selectedIndex;
      }
      
      private function onUpdateFrame() : void
      {
         var _loc4_:Number = NaN;
         this.stopTouchUpdate();
         var _loc1_:Number = this.m_animIndexStart;
         this.m_currentFrame = getTimer();
         var _loc2_:Number = (this.m_currentFrame - this.m_prevFrame) * 0.001;
         this.m_prevFrame = this.m_currentFrame;
         var _loc3_:Number = _loc2_ * this.m_rotateSpeed;
         if(this.m_animDirection > 0)
         {
            _loc4_ = _loc1_ + _loc3_;
            if(_loc4_ >= this.m_itemsInView)
            {
               _loc4_ -= this.m_itemsInView;
               _loc1_ -= this.m_itemsInView;
            }
            if(_loc1_ <= this.m_selectedIndex && _loc4_ >= this.m_selectedIndex)
            {
               _loc4_ = this.m_selectedIndex;
               this.stopUpdateFrame();
            }
         }
         else
         {
            _loc4_ = _loc1_ - _loc3_;
            if(_loc1_ >= this.m_selectedIndex && _loc4_ <= this.m_selectedIndex)
            {
               _loc4_ = this.m_selectedIndex;
               this.stopUpdateFrame();
            }
         }
         this.m_animIndexStart = this.normalizeIndexValue(_loc4_);
         if(!this.m_isRotationRunning)
         {
            this.setSelectedImage();
         }
         this.UpdatePositions();
      }
      
      private function stopUpdateFrame() : void
      {
         if(this.m_isRotationRunning)
         {
            removeEventListener(Event.ENTER_FRAME,this.onUpdateFrame);
            this.m_isRotationRunning = false;
         }
      }
      
      public function OnTouchDragActive(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_isTouchDragActive = true;
            if(!this.m_isUpdateTouchActive)
            {
               this.m_isUpdateTouchActive = true;
               addEventListener(Event.ENTER_FRAME,this.onUpdateTouch);
               this.m_currentFrame = getTimer();
               this.m_prevFrame = this.m_currentFrame;
            }
         }
         else
         {
            this.m_isTouchDragActive = false;
            this.m_touchPos = null;
            this.m_touchPosPrev = null;
         }
      }
      
      public function OnTouchDragX(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.m_isTouchDragActive)
         {
            _loc2_ = 6;
            this.m_touchPos = new Point(param1 * _loc2_,0);
         }
      }
      
      private function handleMouseDown(param1:MouseEvent) : void
      {
         this.OnTouchDragActive(true);
         addEventListener(MouseEvent.MOUSE_MOVE,this.handleMouseMove,false,0,false);
      }
      
      private function handleMouseUp(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.handleMouseMove,false);
         this.OnTouchDragActive(false);
      }
      
      private function handleMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.m_isTouchDragActive)
         {
            this.m_currentFrame = getTimer();
            _loc2_ = MouseUtil.getLocalMousePos(param1,this);
            _loc3_ = 0.005;
            _loc4_ = 1 / this.m_scaleToResolution * _loc3_;
            this.m_touchPos = new Point(_loc2_.x * _loc4_,_loc2_.y * _loc4_);
         }
      }
      
      public function onPan(param1:TransformGestureEvent) : void
      {
         var _loc4_:Point = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:TransformGestureEventEx = param1 as TransformGestureEventEx;
         _loc2_.stopImmediatePropagation();
         var _loc3_:Point = new Point(-_loc2_.offsetX,-_loc2_.offsetY);
         if(_loc2_.inertia == true || _loc2_.phase == GesturePhase.END)
         {
            if(this.m_isTouchDragActive)
            {
               this.OnTouchDragActive(false);
            }
            return;
         }
         if(_loc2_.phase == GesturePhase.BEGIN)
         {
            this.OnTouchDragActive(true);
         }
         if(this.m_isTouchDragActive)
         {
            this.m_currentFrame = getTimer();
            _loc4_ = MouseUtil.getLocalGesturePos(_loc2_,this);
            _loc6_ = _loc5_ = 0.005;
            this.m_touchPos = new Point(_loc4_.x * _loc6_,_loc4_.y * _loc6_);
         }
      }
      
      private function onUpdateTouch() : void
      {
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         if(this.m_isRotationRunning)
         {
            this.stopUpdateFrame();
         }
         if(!this.m_isTouchDragActive)
         {
            this.m_currentFrame = getTimer();
         }
         var _loc1_:Number = (this.m_currentFrame - this.m_prevFrame) * 0.001;
         this.m_prevFrame = this.m_currentFrame;
         if(_loc1_ == 0)
         {
            return;
         }
         if(this.m_isTouchDragActive)
         {
            if(this.m_touchPos == null)
            {
               return;
            }
            if(this.m_touchPosPrev == null)
            {
               this.m_touchPosPrev = this.m_touchPos;
            }
            _loc3_ = this.m_touchPos.subtract(this.m_touchPosPrev);
            this.m_touchPosPrev = this.m_touchPos;
            if(_loc3_.length > 0.00001)
            {
               _loc4_ = _loc3_.clone();
               _loc5_ = _loc4_.x;
               _loc7_ = this.m_animIndexStart + _loc5_;
               _loc7_ = this.normalizeIndexValue(_loc7_);
               this.m_touchAnimationSpeed = Math.abs(_loc5_) / _loc1_;
               this.m_animDirection = _loc5_ > 0 ? 1 : -1;
               this.m_animIndexStart = _loc7_;
               this.UpdatePositions();
            }
            else
            {
               this.m_touchAnimationSpeed = 0;
            }
         }
         else
         {
            _loc6_ = this.m_touchAnimationSpeed * _loc1_;
            this.m_touchAnimationSpeed *= Math.pow(this.TOUCH_ANIMATION_DAMPING,_loc1_);
            _loc7_ = this.m_animIndexStart + _loc6_ * this.m_animDirection;
            _loc7_ = this.normalizeIndexValue(_loc7_);
            this.m_animIndexStart = _loc7_;
            this.UpdatePositions();
            _loc8_ = 1;
            if(this.m_touchAnimationSpeed < _loc8_)
            {
               this.stopTouchUpdate();
               _loc9_ = 0;
               _loc10_ = Math.round(this.m_animIndexStart + _loc9_ * this.m_animDirection);
               _loc11_ = this.m_animIndexStart - _loc10_ < 0 ? 1 : -1;
               _loc10_ = this.normalizeIndexValue(_loc10_);
               this.RotateInternal(_loc10_,_loc11_,1.75);
               _loc12_ = _loc10_;
               sendEventWithValue("setSelectionIndex",_loc12_);
               return;
            }
         }
         var _loc2_:Number = 7;
         if(this.m_touchAnimationSpeed < _loc2_)
         {
            _loc13_ = Math.round(this.m_animIndexStart);
            this.m_selectedIndex = _loc14_ = this.normalizeIndexValue(_loc13_);
            this.setSelectedImage();
            sendEventWithValue("setSelectionIndex",_loc14_);
         }
         else if(this.m_selectedIndex >= 0)
         {
            this.m_selectedIndex = -1;
            this.setSelectedImage();
         }
      }
      
      private function stopTouchUpdate() : void
      {
         if(this.m_isTouchDragActive)
         {
            this.OnTouchDragActive(false);
         }
         if(this.m_isUpdateTouchActive)
         {
            removeEventListener(Event.ENTER_FRAME,this.onUpdateTouch);
            this.m_isUpdateTouchActive = false;
            this.m_touchAnimationSpeed = 0;
         }
      }
      
      private function normalizeIndexValue(param1:Number) : Number
      {
         if(this.m_itemsInView <= 0)
         {
            return 0;
         }
         while(param1 >= this.m_itemsInView)
         {
            param1 -= this.m_itemsInView;
         }
         while(param1 < 0)
         {
            param1 += this.m_itemsInView;
         }
         return param1;
      }
      
      private function loadWeaponImage(param1:int) : void
      {
         var inventoryBgHeight:int = 0;
         var maxHeight:Number = NaN;
         var reducedWidth:Number = NaN;
         var weaponLoader:ImageLoader = null;
         var slotIndex:int = param1;
         var weaponSlot:WeaponSlotView = this.m_aChildrenPool[slotIndex];
         var imagePath:String = this.m_data.mainslotsSlim[slotIndex].icon as String;
         inventoryBgHeight = this.calcInventoryBgHeight();
         maxHeight = inventoryBgHeight - 20;
         reducedWidth = 120;
         weaponLoader = this.m_aChildrenImageLoaderPool[slotIndex];
         weaponLoader.rotation = 0;
         weaponLoader.scaleX = weaponLoader.scaleY = 1;
         weaponLoader.loadImage(imagePath,function():void
         {
            var _loc1_:Boolean = false;
            if(weaponLoader.width > weaponLoader.height)
            {
               weaponLoader.rotation = -90;
               _loc1_ = true;
            }
            weaponLoader.width = reducedWidth;
            weaponLoader.scaleY = weaponLoader.scaleX;
            if(weaponLoader.height > maxHeight)
            {
               weaponLoader.height = maxHeight;
               weaponLoader.scaleX = weaponLoader.scaleY;
            }
            weaponLoader.x = (inventoryBgHeight - 20) / 2 - weaponLoader.width - (reducedWidth - weaponLoader.width) / 2;
            if(_loc1_)
            {
               weaponLoader.y = weaponLoader.height / 2 + (maxHeight - weaponLoader.height) / 2;
            }
            else
            {
               weaponLoader.y = weaponLoader.height / -2 + (maxHeight - weaponLoader.height) / 2;
            }
            m_imageLoadCount += 1;
            loadImageFromQueue();
            if(m_imageLoadCount == m_itemsInView && !m_initialImageLoaded)
            {
               m_initialImageLoaded = true;
               if(m_currentSlotData != null)
               {
                  if(m_currentSlotData.nItemHUDType == 1)
                  {
                     updateItemInformationWithSlotData(m_currentSlotData,slotIndex);
                  }
               }
            }
            if(slotIndex == m_selectedIndex)
            {
               UpdateAmmoDisplayPosition(slotIndex);
            }
            m_aChildrenPool[slotIndex].visible = true;
            UpdatePosition(slotIndex);
         },function():void
         {
            m_imageLoadCount += 1;
            loadImageFromQueue();
            if(m_imageLoadCount == m_itemsInView && !m_initialImageLoaded)
            {
               m_initialImageLoaded = true;
               if(m_currentSlotData != null)
               {
                  if(m_currentSlotData.nItemHUDType == 1)
                  {
                     updateItemInformationWithSlotData(m_currentSlotData,slotIndex);
                  }
               }
            }
         });
      }
      
      private function loadContainedWeaponImage(param1:int) : void
      {
         var imagePath:String;
         var weaponSlot:WeaponSlotView = null;
         var containerClip:MovieClip = null;
         var inventoryBgHeight:int = 0;
         var maxHeight:Number = NaN;
         var reducedWidth:Number = NaN;
         var weaponLoader:ImageLoader = null;
         var slotIndex:int = param1;
         weaponSlot = this.m_aChildrenPool[slotIndex];
         containerClip = weaponSlot.containedWeaponImage_mc;
         containerClip.removeChildren();
         if(this.m_data.mainslotsSlim[slotIndex].containedIcon == null)
         {
            return;
         }
         imagePath = this.m_data.mainslotsSlim[slotIndex].containedIcon as String;
         inventoryBgHeight = this.calcInventoryBgHeight();
         maxHeight = inventoryBgHeight - 20 - 40;
         reducedWidth = 95;
         weaponLoader = this.m_aChildrenImageLoader2Pool[slotIndex];
         weaponLoader.loadImage(imagePath,function():void
         {
            var _loc3_:Bitmap = null;
            var _loc4_:BitmapData = null;
            var _loc5_:Bitmap = null;
            var _loc6_:Bitmap = null;
            var _loc7_:Number = NaN;
            var _loc8_:GlowFilter = null;
            var _loc1_:DisplayObject = weaponLoader.content;
            if(_loc1_ is Bitmap)
            {
               _loc3_ = _loc1_ as Bitmap;
               _loc4_ = _loc3_.bitmapData;
               _loc5_ = new Bitmap(_loc4_);
               _loc6_ = new Bitmap(_loc4_);
               _loc5_.name = "image01";
               _loc6_.name = "image02";
               weaponLoader = null;
               containerClip.addChild(_loc5_);
               containerClip.addChild(_loc6_);
            }
            var _loc2_:Boolean = false;
            if(_loc5_.width > _loc5_.height)
            {
               _loc5_.rotation = -90;
               _loc6_.rotation = -90;
               _loc2_ = true;
            }
            _loc5_.width = _loc6_.width = reducedWidth;
            _loc5_.scaleY = _loc6_.scaleY = _loc5_.scaleX;
            if(_loc5_.height > maxHeight)
            {
               _loc5_.height = _loc6_.height = maxHeight;
               _loc5_.scaleX = _loc6_.scaleX = _loc5_.scaleY;
            }
            _loc5_.x = (inventoryBgHeight - 20) / 2 - _loc5_.width - (reducedWidth - _loc5_.width) / 2 - 40;
            if(_loc2_)
            {
               _loc5_.y = _loc5_.height / 2 + (maxHeight - _loc5_.height) / 2 + 20;
            }
            else
            {
               _loc5_.y = _loc5_.height / -2 + (maxHeight - _loc5_.height) / 2 + 20;
            }
            _loc6_.x = _loc5_.x;
            _loc6_.y = _loc5_.y;
            MenuUtils.setColor(_loc5_,MenuConstants.COLOR_BLACK,false);
            if(ControlsMain.isVrModeActive())
            {
               MenuUtils.setColor(weaponSlot.weaponImage_mc,MenuConstants.COLOR_GREY,false);
               MenuUtils.setColor(_loc6_,MenuConstants.COLOR_GREY_ULTRA_LIGHT,false);
               _loc6_.x -= 4;
               _loc6_.y += 4;
            }
            else
            {
               _loc7_ = Math.max(1,m_fScaleAccum) * PX_BLUR;
               _loc8_ = new GlowFilter();
               _loc8_.color = MenuConstants.COLOR_GREY_ULTRA_LIGHT;
               _loc8_.blurX = _loc8_.blurY = _loc7_;
               _loc8_.knockout = true;
               _loc8_.strength = 20;
               _loc6_.filters = [_loc8_];
               m_imagesThatHaveFilters[_loc6_] = true;
               MenuUtils.trySetCacheAsBitmap(containerClip,true);
            }
            m_aChildrenPool[slotIndex].visible = true;
            UpdatePosition(slotIndex);
         });
      }
      
      public function updatePrompt(param1:Object) : void
      {
         this.m_promptObjPrevious = MenuUtils.parsePrompts(param1,this.m_promptObjPrevious,this.m_promptsContainer,false,this.handlePromptMouseEvent);
         var _loc2_:Number = ControlsMain.getDisplaySize() == ControlsMain.DISPLAY_SIZE_SMALL ? 1.35 : 1;
         this.m_promptsContainer.scaleX = _loc2_;
         this.m_promptsContainer.scaleY = _loc2_;
      }
      
      private function handlePromptMouseEvent(param1:String) : void
      {
         if(param1 == "action-x")
         {
            sendEventWithValue("onInputAction",ButtonPromtUtil.ACTION_ID_INVENTORY_ACTION_X);
         }
         else
         {
            ButtonPromtUtil.handlePromptMouseEvent(sendEventWithValue,param1);
         }
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.visible = param1;
         if(param1)
         {
            this.m_view.alpha = 0;
            Animate.to(this.m_view,0.05,0.2,{"alpha":1},Animate.Linear);
         }
         else
         {
            this.m_currentSlotData = null;
            this.m_textTickerUtilDesc.onUnregister();
            if(this.m_textTicker)
            {
               this.m_textTicker.stopTextTicker(this.m_textObj.tf,this.m_textObj.title);
               this.m_textTicker = null;
            }
            if(this.m_isRotationRunning)
            {
               removeEventListener(Event.ENTER_FRAME,this.onUpdateFrame);
               this.m_isRotationRunning = false;
            }
            if(this.m_previousSelectedIndex >= 0 && this.m_previousSelectedIndex < this.m_aChildrenPool.length)
            {
               Animate.complete(this.m_aChildrenPool[this.m_previousSelectedIndex].weaponImage_mc);
               Animate.complete(this.m_aChildrenPool[this.m_previousSelectedIndex].containedWeaponImage_mc);
               this.m_aChildrenPool[this.m_previousSelectedIndex].weaponImage_mc.y = 0;
               this.m_aChildrenPool[this.m_previousSelectedIndex].containedWeaponImage_mc.y = 0;
            }
            if(this.m_selectedIndex >= 0 && this.m_selectedIndex < this.m_aChildrenPool.length)
            {
               Animate.complete(this.m_aChildrenPool[this.m_selectedIndex].weaponImage_mc);
               Animate.complete(this.m_aChildrenPool[this.m_selectedIndex].containedWeaponImage_mc);
               this.m_aChildrenPool[this.m_selectedIndex].weaponImage_mc.y = 0;
               this.m_aChildrenPool[this.m_selectedIndex].containedWeaponImage_mc.y = 0;
            }
            _loc2_ = 0;
            while(_loc2_ < this.m_itemsInView)
            {
               _loc2_++;
            }
            _loc3_ = 0;
            while(_loc3_ < this.m_aWarnings.length)
            {
               Animate.complete(this.m_aWarnings[_loc3_]);
               _loc3_++;
            }
            this.m_imageLoadCount = 0;
            this.m_initialImageLoaded = false;
            if(this.m_ghostItemIndicatorHolder != null)
            {
               _loc4_ = 0;
               while(_loc4_ < this.m_ghostItemIndicatorHolder.numChildren - 1)
               {
                  this.loopGhostItemIndicators(this.m_ghostItemIndicatorHolder.getChildAt(_loc4_),false);
                  _loc4_++;
               }
            }
            Animate.complete(this.m_view);
            if(this.m_weaponInfo != null)
            {
               Animate.complete(this.m_weaponInfo.line);
            }
         }
      }
      
      override public function onSetViewport(param1:Number, param2:Number, param3:Number) : void
      {
         this.m_viewportScaleX = param1;
         this.m_scaleToResolution = 1 / (Math.min(param1,param2) * param3);
         this.updateBackground();
      }
      
      private function updateBackground() : void
      {
         var _loc1_:int = this.calcInventoryBgWidth();
         var _loc2_:int = this.calcInventoryBgHeight();
         var _loc3_:Number = MenuConstants.BaseWidth / MenuConstants.BaseHeight;
         var _loc4_:Number = Extensions.visibleRect.width / Extensions.visibleRect.height;
         var _loc5_:Number = MenuConstants.BaseHeight / Extensions.visibleRect.height;
         var _loc6_:Number = _loc4_ > _loc3_ ? MenuConstants.BaseWidth * _loc5_ * this.m_viewportScaleX - (MenuConstants.BaseWidth - _loc1_) : _loc1_;
         this.m_background.graphics.clear();
         this.m_background.graphics.beginFill(MenuConstants.COLOR_MENU_TABS_BACKGROUND,0);
         this.m_background.graphics.drawRect(_loc6_ / -2,-100,_loc6_,_loc2_);
         this.m_clickArea.graphics.clear();
         if(ControlsMain.isVrModeActive())
         {
            return;
         }
         this.m_clickArea.graphics.beginFill(16711680,0);
         this.m_clickArea.graphics.drawRect(-this.x * this.m_scaleToResolution,-this.y * this.m_scaleToResolution,Extensions.visibleRect.width * this.m_scaleToResolution,Extensions.visibleRect.height * this.m_scaleToResolution);
         this.m_clickArea.graphics.endFill();
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:DisplayObject = null;
         var _loc6_:Array = null;
         var _loc7_:GlowFilter = null;
         var _loc8_:Number = NaN;
         if(ControlsMain.isVrModeActive())
         {
            return;
         }
         this.m_fScaleAccum = 1;
         var _loc3_:DisplayObject = this;
         do
         {
            this.m_fScaleAccum *= _loc3_.scaleX;
            _loc3_ = _loc3_.parent;
         }
         while(_loc3_ != _loc3_.root);
         
         for(_loc4_ in this.m_imagesThatHaveFilters)
         {
            _loc5_ = _loc4_;
            _loc6_ = _loc5_.filters;
            if(!(_loc6_ == null || _loc6_.length == 0))
            {
               _loc7_ = _loc6_[0] as GlowFilter;
               if(_loc7_ != null)
               {
                  _loc8_ = Math.max(1,this.m_fScaleAccum) * PX_BLUR;
                  _loc7_.blurX = _loc7_.blurY = _loc8_;
                  _loc5_.filters = _loc6_;
               }
            }
         }
      }
   }
}

