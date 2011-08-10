--[[

Tukui_BigWigs skin by Affli@RU-Howling Fjord
All rights reserved.

]]--

-- little config
----------------------------------------
local classcolor = true			-- classcolored bars
local drawshadow = false		-- draw Tukui shadows around frames.
local skinrange = true			-- skin distance window
local disablescaling = true		-- disables bar scaling (including emphasized bars). 
----------------------------------------

-- init Tukui engine
local T, C, L = unpack(Tukui)
if not IsAddOnLoaded("BigWigs") or not C.Addon_Skins.Bigwigs then return end
local barcolor = classcolor and RAID_CLASS_COLORS[T.myclass] -- or {["r"]=.1,["g"]=.1,["b"]=1,} -- uncomment the following to use your own color for the bars
local buttonsize

-- get buttonsize from Tukui
if C.actionbar.buttonsize and type(C.actionbar.buttonsize)=="number" then
	buttonsize=T.Scale(C.actionbar.buttonsize-2)
else
	buttonsize=30	-- just to be safe
end

-- init some tables to store backgrounds
local freebg = {}

-- styling functions
local createbg = function()
	local bg=CreateFrame("Frame")
	bg:SetTemplate("Default")
	if drawshadow then
		bg:CreateShadow("Default")
	end
	return bg
end

local function freestyle(bar)

	-- reparent and hide bar background
	local bg = bar:Get("bigwigs:tukui_bigwigs:bg")
	if bg then
		bg:ClearAllPoints()
		bg:SetParent(UIParent)
		bg:Hide()
		freebg[#freebg + 1] = bg
	end

	-- reparent and hide icon background
	local ibg = bar:Get("bigwigs:tukui_bigwigs:bg")
	if ibg then
		ibg:ClearAllPoints()
		ibg:SetParent(UIParent)
		ibg:Hide()
		freebg[#freebg + 1] = ibg
	end

	-- replace dummies with original method functions
	bar.candyBarBar.SetPoint=bar.candyBarBar.OldSetPoint
	bar.candyBarIconFrame.SetWidth=bar.candyBarIconFrame.OldSetWidth
	if disablescaling then 
		bar.SetScale=bar.OldSetScale
	end
	
end

local applystyle = function(bar)

	-- general bar settings
	bar:SetHeight(buttonsize/4)
	if disablescaling then
		bar:SetScale(1)
		bar.OldSetScale=bar.SetScale
		bar.SetScale=T.dummy
	end

	-- create or reparent and use bar background
	local bg=nil
	if #freebg > 0 then
		bg = table.remove(freebg)
	else
		bg = createbg()
	end
	bg:SetParent(bar)
	bg:ClearAllPoints()
	bg:Point("TOPLEFT", bar, "TOPLEFT", -2, 2)
	bg:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
	bg:SetFrameStrata("BACKGROUND")
	bg:Show()
	bar:Set("bigwigs:tukui_bigwigs:bg", bg)

	-- create or reparent and use icon background
	local ibg=nil
	if bar.candyBarIconFrame:GetTexture() then
		if #freebg > 0 then
			ibg = table.remove(freebg)
		else
			ibg = createbg()
		end
		ibg:SetParent(bar)
		ibg:ClearAllPoints()
		ibg:Point("TOPLEFT", bar.candyBarIconFrame, "TOPLEFT", -2, 2)
		ibg:Point("BOTTOMRIGHT", bar.candyBarIconFrame, "BOTTOMRIGHT", 2, -2)
		ibg:SetFrameStrata("BACKGROUND")
		ibg:Show()
		bar:Set("bigwigs:tukui_bigwigs:bg", ibg)
	end

	-- setup timer and bar name fonts and positions
	bar.candyBarLabel:SetFont(C["media"].pixelfont, 10, "OUTLINE")
	bar.candyBarLabel:SetShadowColor(0, 0, 0, 0)
	bar.candyBarLabel:SetJustifyH("LEFT")
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:Point("BOTTOMLEFT", bar, "TOPLEFT", -2, 4)
	
	bar.candyBarDuration:SetFont(C["media"].pixelfont, 10, "OUTLINE")
	bar.candyBarDuration:SetShadowColor(0, 0, 0, 0)
	bar.candyBarDuration:SetJustifyH("RIGHT")
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:Point("BOTTOMRIGHT", bar, "TOPRIGHT", 2, 4)

	-- setup bar positions and look
	bar.candyBarBar:ClearAllPoints()
	bar.candyBarBar:CreateBorder(false, true)
	bar.candyBarBar:SetAllPoints(bar)
	bar.candyBarBar.OldSetPoint = bar.candyBarBar.SetPoint
	bar.candyBarBar.SetPoint=T.dummy
	bar.candyBarBar:SetStatusBarTexture(C.media.normTex)
	if barcolor and not bar.data["bigwigs:emphasized"]==true then bar.candyBarBar:SetStatusBarColor(barcolor.r, barcolor.g, barcolor.b, 1) end
	bar.candyBarBackground:SetTexture(C.media.normTex)

	-- setup icon positions and other things
	bar.candyBarIconFrame:ClearAllPoints()
	bar.candyBarIconFrame:Point("BOTTOMLEFT", bar, "BOTTOMLEFT", -buttonsize - buttonsize/3 , 0)
	bar.candyBarIconFrame:SetSize(buttonsize, buttonsize)
	bar.candyBarIconFrame.OldSetWidth = bar.candyBarIconFrame.SetWidth
	bar.candyBarIconFrame.SetWidth=T.dummy
	bar.candyBarIconFrame:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end
	

local f = CreateFrame("Frame")

local function registerStyle()
	if not BigWigs then return end
	local bars = BigWigs:GetPlugin("Bars", true)
	local prox = BigWigs:GetPlugin("Proximity", true)
	if bars then
		bars:RegisterBarStyle("Tukui_BigWigs", {
			apiVersion = 1,
			version = 1,
			GetSpacing = function(bar) return buttonsize end,
			ApplyStyle = applystyle,
			BarStopped = freestyle,
			GetStyleName = function() return "Tukui_BigWigs" end,
		})
	end
	if prox and skinrange and BigWigs.pluginCore.modules.Bars.db.profile.barStyle == "Tukui_BigWigs" then
		hooksecurefunc(BigWigs.pluginCore.modules.Proximity, "RestyleWindow", function()
			BigWigsProximityAnchor:SetTemplate("Transparent")
			if drawshadow then
				BigWigsProximityAnchor:CreateShadow("Default")
			end
		end)
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, msg)
	if event == "ADDON_LOADED" then
		if  msg == "BigWigs_Plugins" then
			--[[
			--	BigWigs uses single profile by default, so we should not upload class colors to shared profile. Leaving commented.
				BigWigs.pluginCore.modules.Bars.db.profile.barStyle="Tukui_BigWigs"
				BigWigs3DB.namespaces.BigWigs_Plugins_Colors.profiles.Default.barColor.BigWigs_Plugins_Colors.default={barcolor.r, barcolor.g, barcolor.b}
			]]--	
			registerStyle()
			f:UnregisterEvent("ADDON_LOADED")
		end
	end
end)

local pr = function(msg)
    print("|cffC495DDTukui BigWigs|r:", tostring(msg))
end

SLASH_TUKUIBW1 = "/tukuibigwigs"
SlashCmdList["TUKUIBW"] = function(msg)
	if(msg=="apply") then
		SlashCmdList["BigWigs"]()
		HideUIPanel(InterfaceOptionsFrame)
		StaticPopup_Show("TUKUIBW")        
	elseif(msg=="test") then
		SlashCmdList["BigWigs"]()
		BigWigs.pluginCore.modules.Proximity.Test(BigWigs.pluginCore.modules.Proximity)
		HideUIPanel(InterfaceOptionsFrame)
		BigWigs:Test()
		BigWigs:Test()
		BigWigs:Test()
		BigWigs:Test()
		BigWigs:Test()
		
	else
		pr("use |cffFF0000/tukuibigwigs apply|r to apply BigWigs settings.")
		pr("use |cffFF0000/tukuibigwigs test|r to launch BigWigs testmode.")
	end
end

StaticPopupDialogs["TUKUIBW"] = {
	text = "We need to set some BigWigs options to apply Tukui BigWigs skin.\nMost of your settings will remain untouched.",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		BigWigs.pluginCore.modules.Bars.db.profile.barStyle="Tukui_BigWigs"
		BigWigs.pluginCore.modules.Bars.db.profile.font=C["media"].pixelfont
		BigWigs.pluginCore.modules.Messages.db.profile.font=C["media"].pixelfont
		BigWigs.pluginCore.modules.Messages.db.profile.outline="OUTLINE"
		BigWigs.pluginCore.modules.Proximity.db.profile.font=C["media"].pixelfont

		if InCombatLockdown() then pr(ERR_NOT_IN_COMBAT) pr("Reload your UI to apply skin.") else ReloadUI() end
	end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = true,
}

