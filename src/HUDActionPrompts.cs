package hud
{
   import basic.ButtonPromptImage;
   import common.BaseControl;
   import common.CommonUtils;
   import common.menu.MenuConstants;
   import common.menu.MenuUtils;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mx.utils.StringUtil;
   
   public class HUDActionPrompts extends BaseControl
   {
      
      private const INVISIBLE_ICON_INDEX:int = 65535;
      
      private const IDX_FIRST_EXTRA_PROMPT:int = 4;
      
      private const MAX_PROMPTS:int = 7;
      
      private var m_view:*;
      
      private var m_buttonClips:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      private var m_buttonFontSize:Vector.<int> = new Vector.<int>();
      
      private var m_useNeoVR_view:Boolean = false;
      
      private var m_showExtraButtonsBelow:Boolean = false;
      
      private var m_areExtraButtonsBelow:Boolean = false;
      
      private var m_hintNotActiveFaceButtons:Boolean = false;
      
      private var m_originalPositions:Vector.<Point> = new Vector.<Point>();
      
      private var m_isCustomPositionActive:Boolean = false;
      
      private var m_customPositions:Array = null;
      
      public function HUDActionPrompts()
      {
         super();
         this.CreateView();
         this.m_view.x = 925;
         this.m_view.y = -800;
         this.getButtonClip(2).y = 0;
         this.getButtonClip(3).y = 25;
         this.getButtonClip(0).y = 50;
         this.getButtonClip(1).y = 75;
         this.getButtonClip(5).y = 100;
         this.getButtonClip(6).y = 125;
         this.getButtonClip(4).y = 150;
         this.getButtonClip(0).x = 0;
         this.getButtonClip(1).x = 0;
         this.getButtonClip(2).x = 0;
         this.getButtonClip(3).x = 0;
         this.getButtonClip(4).x = 1;
         this.getButtonClip(5).x = 0;
         this.getButtonClip(6).x = 0;
      }
      
      private function CreateView() : void
      {
         var _loc2_:ButtonPromptImage = null;
         var _loc5_:MovieClip = null;
         var _loc6_:Sprite = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc1_:Boolean = this.m_showExtraButtonsBelow;
         if(this.m_view != null)
         {
            this.m_areExtraButtonsBelow = false;
            this.m_buttonClips.length = 0;
            removeChild(this.m_view);
            this.m_view = null;
         }
         if(this.m_useNeoVR_view)
         {
            this.m_view = new HUDActionPromptsViewNeoVR();
         }
         else
         {
            this.m_view = new HUDActionPromptsView();
         }
         addChild(this.m_view);
         var _loc3_:String = ControlsMain.getControllerType();
         this.m_originalPositions.length = this.MAX_PROMPTS;
         var _loc4_:int = 0;
         while(_loc4_ < this.MAX_PROMPTS)
         {
            _loc5_ = this.getButtonClip(_loc4_);
            _loc2_ = new ButtonPromptImage();
            _loc5_.prompt = _loc5_.promptHolder_mc.addChild(_loc2_);
            _loc5_.prompt.platform = _loc3_;
            if(_loc4_ <= 3)
            {
               _loc5_.prompt.button = _loc4_;
            }
            _loc5_.icon = _loc5_.promptHolder_mc.addChild(new Sprite());
            _loc5_.icon.visible = false;
            _loc6_ = new Sprite();
            _loc6_.graphics.beginFill(16777215);
            _loc6_.graphics.drawCircle(0,0,16);
            _loc6_.graphics.endFill();
            _loc5_.icon.addChild(_loc6_);
            _loc5_.iconview = _loc5_.icon.addChild(new iconsAll76x76View());
            _loc5_.iconview.scaleX = 0.38;
            _loc5_.iconview.scaleY = 0.38;
            _loc5_.visible = false;
            _loc7_ = this.isTxtDirReversed(_loc4_);
            _loc5_.prompt_mc.label_txt.width = 500;
            _loc5_.prompt_mc.desc_txt.width = 500;
            _loc8_ = _loc7_ ? TextFieldAutoSize.RIGHT : TextFieldAutoSize.LEFT;
            _loc5_.prompt_mc.label_txt.autoSize = _loc8_;
            _loc5_.prompt_mc.desc_txt.autoSize = _loc8_;
            this.m_buttonClips.push(_loc5_);
            this.m_originalPositions[_loc4_] = new Point(_loc5_.x,_loc5_.y);
            _loc9_ = MenuConstants.INTERACTIONPROMPTSIZE_DEFAULT;
            this.m_buttonFontSize.push(_loc9_);
            _loc10_ = MenuConstants.InteractionIndicatorFontSpecs[_loc9_];
            MenuUtils.setupText(_loc5_.prompt_mc.label_txt,"",_loc10_.fontSizeLabel,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorWhite);
            MenuUtils.setupText(_loc5_.prompt_mc.desc_txt,"",_loc10_.fontSizeDesc,MenuConstants.FONT_TYPE_NORMAL,MenuConstants.FontColorWhite);
            _loc4_++;
         }
         if(!this.m_useNeoVR_view)
         {
            this.moveExtraButtons(this.m_showExtraButtonsBelow);
         }
      }
      
      private function isTxtDirReversed(param1:int) : Boolean
      {
         if(this.m_isCustomPositionActive)
         {
            return true;
         }
         return param1 == 3 || param1 == 2 && this.m_useNeoVR_view;
      }
      
      private function setupFontSize(param1:int, param2:int) : void
      {
         if(this.m_buttonFontSize[param1] == param2)
         {
            return;
         }
         this.m_buttonFontSize[param1] = param2;
         var _loc3_:MovieClip = this.m_buttonClips[param1];
         var _loc4_:Object = MenuConstants.InteractionIndicatorFontSpecs[param2];
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.size = _loc4_.fontSizeLabel;
         _loc3_.prompt_mc.label_txt.defaultTextFormat = _loc5_;
         var _loc6_:TextFormat = new TextFormat();
         _loc6_.size = _loc4_.fontSizeDesc;
         _loc3_.prompt_mc.desc_txt.defaultTextFormat = _loc6_;
      }
      
      public function set ShowExtraButtonsBelow(param1:Boolean) : void
      {
      }
      
      private function moveExtraButtons(param1:Boolean) : void
      {
         var _loc4_:Number = NaN;
         if(this.m_areExtraButtonsBelow == param1)
         {
            return;
         }
         this.m_areExtraButtonsBelow = param1;
         if(this.m_isCustomPositionActive)
         {
            return;
         }
         var _loc2_:Number = this.m_buttonClips[1].y;
         var _loc3_:int = this.IDX_FIRST_EXTRA_PROMPT;
         while(_loc3_ < this.MAX_PROMPTS)
         {
            _loc4_ = Math.abs(this.m_buttonClips[_loc3_].y - _loc2_);
            this.m_buttonClips[_loc3_].y = _loc2_ + _loc4_ * (param1 ? 1 : -1);
            _loc3_++;
         }
      }
      
      public function set IsNeoVRView(param1:Boolean) : void
      {
         if(this.m_useNeoVR_view == param1)
         {
            return;
         }
         this.m_useNeoVR_view = param1;
         this.CreateView();
      }
      
      public function set HintNotActiveFaceButtons(param1:Boolean) : void
      {
         this.m_hintNotActiveFaceButtons = param1;
      }
      
      public function setCustomPositions(param1:Array) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         var _loc6_:Point = null;
         var _loc7_:int = 0;
         this.m_customPositions = param1;
         var _loc2_:Boolean = param1 != null && param1.length > 0;
         if(_loc2_)
         {
            this.m_isCustomPositionActive = true;
            _loc3_ = this.m_view as MovieClip;
            _loc4_ = _loc3_.localToGlobal(new Point(0,0));
            _loc5_ = 0;
            while(_loc5_ < this.m_buttonClips.length && _loc5_ < param1.length)
            {
               _loc6_ = _loc3_.globalToLocal(new Point(param1[_loc5_].x,param1[_loc5_].y));
               this.m_buttonClips[_loc5_].x = _loc6_.x;
               this.m_buttonClips[_loc5_].y = _loc6_.y;
               _loc5_++;
            }
         }
         else if(this.m_isCustomPositionActive)
         {
            this.m_isCustomPositionActive = false;
            _loc7_ = 0;
            while(_loc7_ < this.m_buttonClips.length)
            {
               this.m_buttonClips[_loc7_].x = this.m_originalPositions[_loc7_].x;
               this.m_buttonClips[_loc7_].y = this.m_originalPositions[_loc7_].y;
               _loc7_++;
            }
            if(this.m_areExtraButtonsBelow)
            {
               this.m_areExtraButtonsBelow = false;
               this.moveExtraButtons(true);
            }
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc11_:MovieClip = null;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc2_:String = ControlsMain.getControllerType();
         var _loc3_:Number = ControlsMain.getDisplaySize() == ControlsMain.DISPLAY_SIZE_SMALL ? 1.25 : 1;
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         var _loc6_:Array = param1 as Array;
         var _loc7_:int = 0;
         var _loc8_:int = 4;
         var _loc9_:int = 1;
         var _loc10_:Vector.<Boolean> = new Vector.<Boolean>(_loc8_);
         _loc7_ = 0;
         while(_loc7_ < _loc6_.length && _loc7_ < this.MAX_PROMPTS)
         {
            _loc11_ = this.m_buttonClips[_loc7_];
            _loc12_ = _loc6_[_loc7_];
            if(_loc7_ < _loc8_)
            {
               _loc10_[_loc7_] = _loc12_.m_bActive;
            }
            _loc11_.visible = _loc12_.m_bActive;
            _loc11_.scaleX = _loc3_;
            _loc11_.scaleY = _loc3_;
            if(_loc12_.m_bActive)
            {
               _loc5_ ||= _loc7_ < _loc8_ && _loc7_ != _loc9_;
               _loc13_ = _loc12_.m_nFontSize ? int(_loc12_.m_nFontSize) : MenuConstants.INTERACTIONPROMPTSIZE_DEFAULT;
               _loc4_ = MenuConstants.InteractionIndicatorFontSpecs[_loc13_];
               _loc11_.scaleX *= _loc4_.fScaleIndividual;
               _loc11_.scaleY *= _loc4_.fScaleIndividual;
               this.setupFontSize(_loc7_,_loc13_);
               _loc14_ = true;
               this.showActionButton(_loc11_,_loc12_,_loc14_,_loc2_);
            }
            _loc7_++;
         }
         if(this.m_hintNotActiveFaceButtons && _loc5_)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc8_)
            {
               this.m_buttonClips[_loc7_].visible = true;
               if(!_loc10_[_loc7_])
               {
                  this.hintActionButton(this.m_buttonClips[_loc7_],this.getDefaultButtonId(_loc7_),_loc2_);
               }
               _loc7_++;
            }
         }
         if(_loc4_ != null)
         {
            if(this.m_view.scaleX != _loc4_.fScaleGroup || this.m_view.scaleY != _loc4_.fScaleGroup)
            {
               this.m_view.scaleX = _loc4_.fScaleGroup;
               this.m_view.scaleY = _loc4_.fScaleGroup;
               this.setCustomPositions(this.m_customPositions);
            }
         }
      }
      
      private function showActionButton(param1:MovieClip, param2:Object, param3:Boolean, param4:String) : void
      {
         var _loc18_:Number = NaN;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc5_:int = int(param2.m_nIconId);
         var _loc6_:String = param2.m_sLabel;
         var _loc7_:String = param2.m_sCustomIcon;
         var _loc8_:String = param2.m_sDescription;
         var _loc9_:Boolean = Boolean(param2.m_bIllegalItem);
         var _loc10_:Boolean = Boolean(param2.m_bSuspiciousItem);
         var _loc11_:Number = Number(param2.m_fProgress);
         var _loc12_:Boolean = Boolean(param2.m_bNoActionAvailable);
         var _loc13_:Number = Number(param2.m_eTypeId);
         var _loc14_:String = param2.m_sGlyph;
         var _loc15_:Boolean = Boolean(param2.m_bDropTempHolsterableItems);
         if(param2.m_bShowWarning)
         {
            _loc9_ = true;
         }
         if(_loc5_ == this.INVISIBLE_ICON_INDEX)
         {
            param1.visible = false;
            return;
         }
         if(_loc7_ != null && _loc7_.length > 0)
         {
            param1.prompt.visible = false;
            param1.icon.visible = true;
            MenuUtils.setupIcon(param1.iconview,_loc7_,0,false,false,16777215,1,0,false);
         }
         else
         {
            param1.prompt.visible = true;
            param1.icon.visible = false;
         }
         var hideTop:Boolean = _loc6_ != null && (_loc6_.charAt(0) == "_" || _loc6_.charAt(0) == "^" || _loc6_.charAt(0) == "+" || _loc6_.charAt(0) == ",");
         var hasPrefix:Boolean = _loc6_ != null && (_loc6_.charAt(0) == "-" || _loc6_.charAt(0) == "=" || _loc6_.charAt(0) == "." || _loc6_.charAt(0) == "$" || _loc6_.charAt(0) == "%" || hideTop);
         if(hasPrefix)
         {
            _loc6_ = _loc6_.substr(1);
         }
         var _loc16_:Object = MenuConstants.InteractionIndicatorFontSpecs[param2.m_nFontSize ? param2.m_nFontSize : MenuConstants.INTERACTIONPROMPTSIZE_DEFAULT];
         var _loc17_:int = _loc9_ || _loc10_ ? 81 : 1;
         param1.illegalIcon_mc.visible = false;
         param1.prompt_mc.x = param3 ? -28 : 28;
         param1.prompt.alpha = _loc12_ ? 0.33 : 1;
         param1.icon.alpha = param1.prompt.alpha;
         param1.prompt_mc.label_txt.visible = true;
         param1.prompt_mc.label_txt.htmlText = _loc6_;
         _loc8_ = StringUtil.trim(_loc8_);
         if(Boolean(_loc8_) && _loc8_.length > 0)
         {
            var descHideTop:Boolean = _loc8_ != null && (_loc8_.charAt(0) == "_" || _loc8_.charAt(0) == "^" || _loc8_.charAt(0) == "+" || _loc8_.charAt(0) == ",");
            var descHasPrefix:Boolean = descHideTop || _loc8_ != null && (_loc8_.charAt(0) == "-" || _loc8_.charAt(0) == "=" || _loc8_.charAt(0) == "." || _loc8_.charAt(0) == "$" || _loc8_.charAt(0) == "%");
            if(descHasPrefix)
            {
               _loc8_ = _loc8_.substr(1);
            }
            if(hideTop || descHideTop)
            {
               param1.prompt_mc.desc_txt.visible = false;
               param1.prompt_mc.desc_txt.text = "";
               param1.prompt_mc.label_txt.y = _loc16_.yOffsetLabelSolo;
               param1.prompt_mc.label_txt.htmlText = _loc8_;
            }
            else
            {
               param1.prompt_mc.desc_txt.visible = true;
               param1.prompt_mc.desc_txt.htmlText = _loc8_;
               param1.prompt_mc.label_txt.y = _loc16_.yOffsetLabel;
               param1.prompt_mc.desc_txt.y = _loc16_.yOffsetDesc;
            }
         }
         else
         {
            param1.prompt_mc.desc_txt.visible = false;
            param1.prompt_mc.desc_txt.text = "";
            param1.prompt_mc.label_txt.y = _loc16_.yOffsetLabelSolo;
         }
         if(_loc10_)
         {
            param1.illegalIcon_mc.visible = false;
         }
         else if(_loc9_)
         {
            param1.illegalIcon_mc.visible = false;
         }
         else
         {
            param1.illegalIcon_mc.visible = false;
         }
         param1.prompt.scaleX = param1.prompt.scaleY = param4 == "key" ? 0.6 : 0.7;
         if(_loc5_ == -1)
         {
            param1.prompt.customKey = _loc14_;
         }
         else
         {
            param1.prompt.platform = param4;
            param1.prompt.button = _loc5_;
         }
         if(_loc13_ == 2 || _loc13_ == 3)
         {
            if(_loc11_ > 0)
            {
               if(ControlsMain.getControllerType() == CommonUtils.CONTROLLER_TYPE_TOUCHINPUT)
               {
                  param1.hold_mc.scaleX = 3;
                  param1.hold_mc.scaleY = 3;
               }
               param1.hold_mc.gotoAndStop(Math.ceil(_loc11_ * 60) + _loc17_);
            }
            else
            {
               param1.hold_mc.scaleX = 1;
               param1.hold_mc.scaleY = 1;
               param1.hold_mc.gotoAndStop(_loc17_);
            }
            param1.hold_mc.visible = true;
            param1.tap_mc.visible = false;
         }
         else if(_loc13_ == 4)
         {
            param1.tap_mc.visible = true;
            param1.tap_mc.play();
         }
         else
         {
            param1.tap_mc.visible = false;
            param1.hold_mc.visible = false;
         }
         if(param1.hold_mc.visible)
         {
            param1.prompt_mc.label_txt.x = param3 ? 1 - param1.prompt_mc.label_txt.textWidth : -3;
            param1.prompt_mc.desc_txt.x = param3 ? 1 - param1.prompt_mc.desc_txt.textWidth : -3;
         }
         else
         {
            param1.prompt_mc.label_txt.x = param3 ? 5 - param1.prompt_mc.label_txt.textWidth : -7;
            param1.prompt_mc.desc_txt.x = param3 ? 5 - param1.prompt_mc.desc_txt.textWidth : -7;
         }
      }
      
      private function hintActionButton(param1:MovieClip, param2:int, param3:String) : void
      {
         if(param3 == "key" || param2 == -1)
         {
            return;
         }
         param1.visible = true;
         param1.prompt.alpha = 0.33;
         param1.prompt_mc.label_txt.visible = false;
         param1.prompt_mc.desc_txt.visible = false;
         param1.illegalIcon_mc.visible = false;
         param1.prompt.platform = param3;
         param1.prompt.button = param2;
         param1.tap_mc.visible = false;
         param1.hold_mc.visible = false;
      }
      
      private function getDefaultButtonId(param1:int) : int
      {
         if(param1 == 0)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 4;
         }
         return param1;
      }
      
      private function getButtonClip(param1:int) : MovieClip
      {
         return this.m_view.getChildByName("button0" + String(param1 + 1) + "_button_mc") as MovieClip;
      }
   }
}

