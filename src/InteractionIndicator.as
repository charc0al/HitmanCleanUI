package hud
{
   import basic.ButtonPromptImage;
   import common.BaseControl;
   import common.CommonUtils;
   import common.menu.MenuConstants;
   import common.menu.MenuUtils;
   import flash.display.Sprite;
   import flash.text.TextFieldAutoSize;
   import mx.utils.StringUtil;
   
   public class InteractionIndicator extends BaseControl
   {
      
      public static const STATE_AVAILABLE:int = 0;
      
      public static const STATE_COLLAPSED:int = 1;
      
      public static const STATE_ACTIVATING:int = 2;
      
      public static const STATE_NOTAVAILABLE:int = 3;
      
      public static const TYPE_UNKNOWN:int = 0;
      
      public static const TYPE_PRESS:int = 1;
      
      public static const TYPE_HOLD:int = 2;
      
      public static const TYPE_HOLD_DOWN:int = 3;
      
      public static const TYPE_REPEAT:int = 4;
      
      public static const TYPE_GUIDE:int = 5;
      
      private static const ILLEGAL_ACTION_TEXT_COLOR:uint = 16748688;
      
      private var m_view:InteractionIndicatorView;
      
      private var m_promptImage:ButtonPromptImage;
      
      private var m_icon:Sprite;
      
      private var m_iconView:iconsAll76x76View;
      
      private var m_currentProgress:Number;
      
      private var m_nFontSizeCurrent:int;
      
      private var m_sLabelCurrent:String = "";
      
      private var m_sDescriptionCurrent:String = "";
      
      private var m_holdAnimFrameOffset:int;
      
      private var m_viewportScale:Number = 1;
      
      public function InteractionIndicator()
      {
         super();
         this.m_view = new InteractionIndicatorView();
         addChild(this.m_view);
         this.m_promptImage = new ButtonPromptImage();
         this.m_view.promptHolder_mc.addChild(this.m_promptImage);
         this.m_iconView = new iconsAll76x76View();
         this.m_iconView.scaleX = 0.38;
         this.m_iconView.scaleY = 0.38;
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(16777215);
         _loc1_.graphics.drawCircle(0,0,16);
         _loc1_.graphics.endFill();
         this.m_icon = new Sprite();
         this.m_icon.addChild(_loc1_);
         this.m_icon.addChild(this.m_iconView);
         this.m_icon.visible = false;
         this.m_view.promptHolder_mc.addChild(this.m_icon);
         this.m_nFontSizeCurrent = ControlsMain.getDisplaySize() == ControlsMain.DISPLAY_SIZE_SMALL ? MenuConstants.INTERACTIONPROMPTSIZE_FORCEDONSMALLDISPLAY : int(CommonUtils.getUIOptionValueNumber("UI_OPTION_GAME_AID_INTERACTION_PROMPT"));
         this.setupTextFields();
      }
      
      private function setupTextFields() : void
      {
         var _loc1_:Object = MenuConstants.InteractionIndicatorFontSpecs[this.m_nFontSizeCurrent];
         MenuUtils.setupText(this.m_view.prompt_mc.label_txt,this.m_sLabelCurrent,_loc1_.fontSizeLabel,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorWhite);
         MenuUtils.setupText(this.m_view.prompt_mc.desc_txt,this.m_sDescriptionCurrent,_loc1_.fontSizeDesc,MenuConstants.FONT_TYPE_NORMAL,MenuConstants.FontColorWhite);
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc2_:int = param1.m_nFontSize ? int(param1.m_nFontSize) : 0;
         if(_loc2_ != this.m_nFontSizeCurrent)
         {
            this.m_nFontSizeCurrent = _loc2_;
            this.setupTextFields();
         }
         this.updateScale();
         if(param1.m_bHidePrompt != undefined)
         {
            this.m_view.promptHolder_mc.visible = !param1.m_bHidePrompt;
         }
         if(param1.m_eState == STATE_AVAILABLE)
         {
            this.m_promptImage.alpha = param1.m_bNoActionAvailable ? 0.33 : 1;
            this.m_icon.alpha = this.m_promptImage.alpha;
            this.m_holdAnimFrameOffset = Boolean(param1.m_bIllegal) || Boolean(param1.m_bIllegalItem) || Boolean(param1.m_bSuspiciousItem) ? 81 : 1;
            this.m_view.prompt_mc.x = param1.m_bIsTxtDirReversed ? -28 : 28;
            if(param1.m_eTypeId == TYPE_HOLD || param1.m_eTypeId == TYPE_HOLD_DOWN)
            {
               this.m_view.tap_mc.visible = false;
               this.m_view.hold_mc.visible = true;
               this.m_view.hold_mc.scaleX = 1;
               this.m_view.hold_mc.scaleY = 1;
               this.m_view.hold_mc.gotoAndStop(this.m_holdAnimFrameOffset);
            }
            else if(param1.m_eTypeId == TYPE_REPEAT)
            {
               this.m_view.hold_mc.visible = false;
               this.m_view.tap_mc.visible = true;
               this.m_view.tap_mc.play();
            }
            else
            {
               this.m_view.tap_mc.visible = false;
               this.m_view.hold_mc.visible = false;
            }
            this.showActionButton(param1.m_nIconId,param1.m_sLabel,param1.m_sDescription,param1.m_sGlyph,param1.m_sCustomIcon,param1.m_bIllegalItem,param1.m_bIllegal,param1.m_bSuspiciousItem,param1.m_bIsTxtDirReversed,param1.m_bHidePrompt,param1.m_bIsActionBlocked);
            this.m_view.collapsedEmpty_mc.alpha = 0;
            this.m_view.collapsedFull_mc.alpha = 0;
            this.m_view.prompt_mc.visible = true;
            if(ControlsMain.isVrModeActive())
            {
               this.m_view.alpha = 0.6;
            }
         }
         else if(param1.m_eState == STATE_COLLAPSED || param1.m_eState == STATE_NOTAVAILABLE)
         {
            this.m_promptImage.visible = false;
            this.m_icon.visible = false;
            this.m_view.prompt_mc.visible = false;
            this.m_view.tap_mc.visible = false;
            this.m_view.hold_mc.visible = false;
            this.m_view.illegalIcon_mc.visible = false;
            if(param1.m_bInRange)
            {
               this.m_view.collapsedFull_mc.alpha = 0;
               this.m_view.collapsedEmpty_mc.alpha = 0;
            }
            else if(param1.m_bContainsItem)
            {
               this.m_view.collapsedFull_mc.alpha = 0;
               this.m_view.collapsedEmpty_mc.alpha = 0;
            }
            else
            {
               this.m_view.collapsedFull_mc.alpha = 0;
               this.m_view.collapsedEmpty_mc.alpha = 0;
            }
            if(ControlsMain.isVrModeActive())
            {
               this.m_view.alpha = 1;
            }
         }
         else if(param1.m_eState == STATE_ACTIVATING)
         {
            if(param1.m_fProgress > 0)
            {
               this.m_view.hold_mc.visible = true;
               if(ControlsMain.getControllerType() == CommonUtils.CONTROLLER_TYPE_TOUCHINPUT)
               {
                  this.m_view.hold_mc.scaleX = 3;
                  this.m_view.hold_mc.scaleY = 3;
               }
               if(this.m_currentProgress != param1.m_fProgress)
               {
                  this.m_view.hold_mc.gotoAndStop(Math.ceil(param1.m_fProgress * 60) + this.m_holdAnimFrameOffset);
                  this.m_currentProgress = param1.m_fProgress;
               }
            }
            else
            {
               this.m_view.hold_mc.visible = false;
            }
            this.showActionButton(param1.m_nIconId,param1.m_sLabel,param1.m_sDescription,param1.m_sGlyph,param1.m_sCustomIcon,param1.m_bIllegalItem,param1.m_bIllegal,param1.m_bSuspiciousItem,param1.m_bIsTxtDirReversed,param1.m_bHidePrompt,param1.m_bIsActionBlocked);
            this.m_view.collapsedEmpty_mc.alpha = 0;
            this.m_view.collapsedFull_mc.alpha = 0;
            this.m_view.tap_mc.visible = false;
            this.m_view.prompt_mc.visible = true;
            if(ControlsMain.isVrModeActive())
            {
               this.m_view.alpha = 0.6;
            }
         }
      }
      
      public function setScaleFactor3D(param1:Number) : void
      {
         this.m_view.collapsedEmpty_mc.scaleX = this.m_view.collapsedEmpty_mc.scaleY = param1;
         this.m_view.collapsedFull_mc.scaleX = this.m_view.collapsedFull_mc.scaleY = param1;
      }
      
      private function showActionButton(param1:int, param2:String, param3:String, param4:String, param5:String, param6:Boolean, param7:Boolean, param8:Boolean, param9:Boolean, param10:Boolean, param11:Boolean) : void
      {
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:String = null;
         param2 = StringUtil.trim(param2);
         param3 = StringUtil.trim(param3);
         var _loc12_:Boolean = param11 === true && ControlsMain.isVrModeActive();
         this.m_view.illegalIcon_mc.visible = false;
         this.m_view.prompt_mc.x = param9 ? -28 : 28;
         this.m_view.prompt_mc.label_txt.autoSize = param9 ? TextFieldAutoSize.LEFT : TextFieldAutoSize.RIGHT;
         this.m_view.prompt_mc.desc_txt.autoSize = param9 ? TextFieldAutoSize.LEFT : TextFieldAutoSize.RIGHT;
         var _loc20_:uint = param6 || param7 ? ILLEGAL_ACTION_TEXT_COLOR : 16777215;
         this.m_view.prompt_mc.label_txt.textColor = _loc20_;
         this.m_view.prompt_mc.desc_txt.textColor = _loc20_;
         this.m_promptImage.platform = ControlsMain.getControllerType();
         this.m_view.promptHolder_mc.scaleX = this.m_view.promptHolder_mc.scaleY = this.m_promptImage.platform == "key" ? 0.6 : 0.7;
         if(param5 != null && param5.length > 0)
         {
            this.m_promptImage.visible = false;
            this.m_icon.visible = true;
            MenuUtils.setupIcon(this.m_iconView,param5,0,false,false,16777215,1,0,false);
         }
         else
         {
            this.m_promptImage.visible = true;
            this.m_icon.visible = false;
            if(param1 != -1)
            {
               this.m_promptImage.button = param1;
            }
            else
            {
               this.m_promptImage.customKey = param4;
            }
         }
         var labelWasVisible:Boolean = Boolean(this.m_view.prompt_mc.label_txt.visible);
         var descWasVisible:Boolean = Boolean(this.m_view.prompt_mc.desc_txt.visible);
         var _loc13_:String = param2 != null ? String(param2) : "";
         var c:String = _loc13_.length > 0 ? _loc13_.charAt(0) : "";
         var forceHideAllText:Boolean = c == "-" || c == "_" || c == "+" || c == "=";
         var hideTop:Boolean = c == "-" || c == "^" || c == ",";
         var hideEverything:Boolean = c == "_" || c == "+" || c == "=";
         var hideBottom:Boolean = hideEverything || c == "$" || c == "%";
         var hidePrompt:Boolean = c == "+" || c == "=" || c == "." || c == "," || c == "%";
         if(hideTop || hidePrompt || hideEverything || hideBottom)
         {
            _loc13_ = _loc13_.substr(1);
         }
         if(hidePrompt)
         {
            this.m_promptImage.visible = false;
         }
         if(hideTop || hideEverything)
         {
            this.m_view.prompt_mc.label_txt.visible = false;
            this.m_view.prompt_mc.label_txt.htmlText = "";
            this.m_sLabelCurrent = "";
            if(hideEverything)
            {
               _loc13_ = "";
            }
         }
         else
         {
            this.m_view.prompt_mc.label_txt.visible = true;
         }
         if(this.m_view.prompt_mc.label_txt.visible)
         {
            if(_loc13_ != this.m_sLabelCurrent || !labelWasVisible)
            {
               this.m_view.prompt_mc.label_txt.htmlText = _loc13_;
               this.m_sLabelCurrent = _loc13_;
            }
         }
         var _loc14_:Object = MenuConstants.InteractionIndicatorFontSpecs[this.m_nFontSizeCurrent];
         if(Boolean(param3) && param3.length > 0)
         {
            _loc19_ = param3 != null ? String(param3) : "";
            var descC:String = _loc19_.length > 0 ? _loc19_.charAt(0) : "";
            var descHideAll:Boolean = descC == "=" || descC == "+";
            var descHideEverything:Boolean = descHideAll || _loc19_ == "NOT FOUND";
            var descHideBoth:Boolean = descHideEverything || descC == "_";
            var descHideTop:Boolean = descHideBoth || descC == "," || descC == "-" || descC == "^";
            var descHideButton:Boolean = descHideEverything || descC == "." || descC == ",";
            if(descHideTop || descHideBoth || descHideButton || descHideAll)
            {
               _loc19_ = _loc19_.substr(1);
            }
            if(descHideButton)
            {
               this.m_promptImage.visible = false;
            }
            if(descHideBoth || descHideEverything)
            {
               this.m_view.prompt_mc.desc_txt.visible = false;
               this.m_view.prompt_mc.label_txt.visible = false;
               this.m_view.prompt_mc.desc_txt.text = "";
               this.m_view.prompt_mc.label_txt.text = "";
               this.m_sDescriptionCurrent = "";
               this.m_sLabelCurrent = "";
            }
            else if(!(hideTop || descHideTop))
            {
               this.m_view.prompt_mc.desc_txt.visible = true;
               this.m_view.prompt_mc.label_txt.visible = true;
               if(_loc19_ != this.m_sDescriptionCurrent || !descWasVisible)
               {
                  this.m_view.prompt_mc.desc_txt.htmlText = _loc19_;
                  this.m_sDescriptionCurrent = _loc19_;
               }
               this.m_view.prompt_mc.label_txt.y = _loc14_.yOffsetLabel;
               this.m_view.prompt_mc.desc_txt.y = _loc14_.yOffsetDesc;
            }
            else
            {
               this.m_view.prompt_mc.desc_txt.visible = false;
               this.m_view.prompt_mc.desc_txt.text = "";
               this.m_sDescriptionCurrent = "";
               this.m_view.prompt_mc.label_txt.visible = true;
               this.m_view.prompt_mc.label_txt.y = _loc14_.yOffsetLabelSolo;
               if(_loc19_ != this.m_sLabelCurrent || !labelWasVisible)
               {
                  this.m_view.prompt_mc.label_txt.htmlText = _loc19_;
                  this.m_sLabelCurrent = _loc19_;
               }
            }
            if(hideBottom && !descHideTop)
            {
               this.m_view.prompt_mc.desc_txt.visible = false;
               this.m_view.prompt_mc.desc_txt.text = "";
               this.m_sDescriptionCurrent = "";
               this.m_view.prompt_mc.label_txt.visible = true;
               this.m_view.prompt_mc.label_txt.y = _loc14_.yOffsetLabelSolo;
            }
         }
         else
         {
            this.m_view.prompt_mc.desc_txt.visible = false;
            this.m_view.prompt_mc.desc_txt.text = "";
            this.m_sDescriptionCurrent = "";
            this.m_view.prompt_mc.label_txt.visible = true;
            this.m_view.prompt_mc.label_txt.y = _loc14_.yOffsetLabelSolo;
            if(this.m_view.prompt_mc.label_txt.visible && !labelWasVisible && _loc13_ != this.m_sLabelCurrent)
            {
               this.m_view.prompt_mc.label_txt.htmlText = _loc13_;
               this.m_sLabelCurrent = _loc13_;
            }
         }
         if(_loc12_)
         {
            this.m_view.illegalIcon_mc.visible = true;
            this.m_view.illegalIcon_mc.gotoAndStop("unavailable");
         }
         else if(param8)
         {
            this.m_view.illegalIcon_mc.visible = false;
         }
         else if(param7 || param6)
         {
            this.m_view.illegalIcon_mc.visible = false;
         }
         else
         {
            this.m_view.illegalIcon_mc.visible = false;
         }
         var _loc15_:int = this.m_view.hold_mc.visible ? -3 : -7;
         if(param9)
         {
            this.m_view.prompt_mc.label_txt.x = -_loc15_ - this.m_view.prompt_mc.label_txt.width;
            this.m_view.prompt_mc.desc_txt.x = -_loc15_ - this.m_view.prompt_mc.desc_txt.width;
         }
         else
         {
            this.m_view.prompt_mc.label_txt.x = _loc15_;
            this.m_view.prompt_mc.desc_txt.x = _loc15_;
         }
         if(forceHideAllText)
         {
            this.m_view.prompt_mc.label_txt.visible = false;
            this.m_view.prompt_mc.label_txt.text = "";
            this.m_sLabelCurrent = "";
            this.m_view.prompt_mc.desc_txt.visible = false;
            this.m_view.prompt_mc.desc_txt.text = "";
            this.m_sDescriptionCurrent = "";
         }
      }
      
      override public function onSetViewport(param1:Number, param2:Number, param3:Number) : void
      {
         this.m_viewportScale = Math.min(param1,param2);
         this.updateScale();
      }
      
      private function updateScale() : void
      {
         var _loc1_:Boolean = !ControlsMain.isVrModeActive() && ControlsMain.getDisplaySize() == ControlsMain.DISPLAY_SIZE_SMALL;
         var _loc2_:Number = _loc1_ ? 1.25 : 1;
         var _loc3_:Object = MenuConstants.InteractionIndicatorFontSpecs[this.m_nFontSizeCurrent];
         this.m_view.scaleX = this.m_viewportScale * _loc2_ * _loc3_.fScaleGroup * _loc3_.fScaleIndividual;
         this.m_view.scaleY = this.m_viewportScale * _loc2_ * _loc3_.fScaleGroup * _loc3_.fScaleIndividual;
      }
   }
}


