global struct_guiForm
try(
	struct_guiForm.maxForm.close()
	)
catch()

struct struct_guiForm (

	maxForm = dotNetObject "MaxCustomControls.MaxForm",
	tl = dotnetObject "DevExpress.XtraTreeList.TreeList",
	f, --placeholder for eventhandlers
	riCheck=dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemCheckEdit",
	xTraSpinner=dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemSpinEdit",
	btnRefresh = dotNetObject "System.Windows.Forms.Button",

	HasNormal=1,
	HasSmoothNormal=1,
	FilePath="",
	SimpleTex = false,
	FPS = 0,
	K_Count =0,
	defanim=0,

	msaExportMorph=false,
	msaExportLink =false,
	msaExportTex = false,
	msaExportRangeStart =0,
	msaExportRangeEnd =0,
	msaExportCopyTex = false	,
	
	inTreeObj=#(), -- обьявление здесь для видимости

	fn fn_initForm control = (
		--init the form
		control.Size = dotNetObject "System.Drawing.Size" 700 500
		control.Text = "Export properties"

		btnRefresh.text = "Refresh"
		btnRefresh.width = 64
		btnRefresh.height =45
		btnRefresh.location = dotNetObject "System.Drawing.Point" 74 425 -- добавить контроль при ресайзе
		MaxForm.controls.add btnRefresh
		
		MaxForm.MinimumSize =  dotNetObject "System.Drawing.Size" 700 150
	),

	fn fn_initTl control = (
		control.Size = dotNetObject "System.Drawing.Size" 690 420
	),

	fn fn_populate control = (
		xtl=control
		xtl.OptionsSelection.MultiSelect = true
		xtl.OptionsView.ShowRoot =true
		xtl.OptionsView.ShowIndicator = true
		xtl.OptionsView.AutoWidth = true

		col=xtl.columns.add()
		col.visible=true
		col.caption="Objects"
		col.OptionsColumn.AllowEdit=false
		col.width=200
		xtl.columns.item[0].fixed = xtl.columns.item[0].fixed.none

		col=xtl.columns.add()
		col.visible=true
		col.caption="Export"
		col.width=30
		
		xtl.RepositoryItems.add riCheck
		col.columnEdit=riCheck

		col=xtl.columns.add()
		col.visible=true
		col.caption="Anim Link"
		col.width=40
		col.columnEdit=riCheck

		col=xtl.columns.add()
		col.visible=true
		col.caption="Anim Morph"
		col.width=55
		col.columnEdit=riCheck

		col=xtl.columns.add()
		col.visible=true
		col.caption="Texture"
		col.width=30
		col.columnEdit=riCheck

		col=xtl.columns.add()
		col.visible=true
		col.caption="Copy texture"
		col.width=55
		col.columnEdit=riCheck

		col=xtl.columns.add()
		col.visible=true
		col.caption="Start frame"
		col.width=45
		
		xTraSpinner.SpinStyle=xTraSpinner.SpinStyle.vertical
		xTraSpinner.minValue=animationRange.Start.frame
		xTraSpinner.maxValue=animationRange.End.frame
		xTraSpinner.Increment=1
		xTraSpinner.UseCtrlIncrement=true
		xTraSpinner.isFloatValue=false
		xTraSpinner.AllowNullInput=xTraSpinner.AllowNullInput.false
		xTraSpinner.nulltext="--- "
		xtl.RepositoryItems.add xTraSpinner
		col.columnEdit=xTraSpinner
		col.UnboundType=col.UnboundType.Decimal

		col=xtl.columns.add()
		col.visible=true
		col.caption="End frame"
		col.width=40
		
		xTraSpinner.SpinStyle=xTraSpinner.SpinStyle.vertical
		xTraSpinner.minValue=animationRange.Start.frame
		xTraSpinner.maxValue=animationRange.End.frame
		xTraSpinner.Increment=1
		xTraSpinner.UseCtrlIncrement=true
		xTraSpinner.isFloatValue=false
		xTraSpinner.AllowNullInput=xTraSpinner.AllowNullInput.false
		xTraSpinner.nulltext="--- "
		xtl.RepositoryItems.add xTraSpinner
		col.columnEdit=xTraSpinner
		col.UnboundType=col.UnboundType.Decimal
	),

	fn addChildren xtl theNode theChildren =(
		for c in theChildren do	(
		
			-- чтение User Defined Properties
			
			msaExport=getUserProp  c "msaExport"
			if msaExport==undefined then msaExport=false
				
			msaExportLink=getUserProp  c "msaExportLink"
			if msaExportLink==undefined then msaExportLink=false
				
			msaExportMorph=getUserProp  c "msaExportMorph"
			if msaExportMorph==undefined then msaExportMorph=false
				
			msaExportTex=getUserProp  c "msaExportTex"
			if msaExportTex==undefined then msaExportTex=false
				
			msaExportCopyTex=getUserProp  c "msaExportCopyTex"
			if msaExportCopyTex==undefined then msaExportCopyTex=false
			
			msaExportRangeStart=getUserProp  c "msaExportRangeStart"
			if classOf(msaExportRangeStart)!=integer then msaExportRangeStart=animationRange.Start.frame
			
			msaExportRangeEnd=getUserProp  c "msaExportRangeEnd"
			if classOf(msaExportRangeEnd)!=integer then msaExportRangeEnd=animationRange.End.frame
				
			-- name, export, link, morph, texture, copy tex, start frame, end frame
			
			newNode = xtl.appendNode #(\
				c.name,\
				msaExport,\
				msaExportLink,\
				msaExportMorph,\
				msaExportTex,\
				msaExportCopyTex,\
				msaExportRangeStart,\
				msaExportRangeEnd\
				) theNode.id
			
			-- cleanup
			
			msaExport=undefined
			msaExportLink=undefined
			msaExportMorph=undefined
			msaExportTex=undefined
			msaExportCopyTex=undefined
			msaExportRangeStart=undefined
			msaExportRangeEnd=undefined
			
			append inTreeObj c
			addChildren xtl newNode c.children
		)
	),

	fn addTargetNamesToEtl xtl =(
		xtl.ClearNodes()
		theNodes=objects as array
		n=#()
		
		-- name, export, link, morph, texture, copy tex, start frame, end frame
		
		theRoot = xtl.appendNode #("root",false,false,false,false,false,"---","---") -1
		rootNodes =for o in objects where o.parent == undefined collect o
		inTreeObj = #() -- очистка
		addChildren xtl theRoot rootNodes
		xtl.ExpandAll()
	),

	initForm = fn_initForm maxForm,
	initTl = fn_initTl tl,
	populateTl = fn_populate tl,
	tn = addTargetNamesToEtl tl,
	assembleForm = maxForm.controls.add tl,
	showForm = maxForm.ShowModeless(),
	
	-- Resize
	
	fn resizeFrm control arg = (
		tl.Size = dotNetObject "System.Drawing.Size" (maxForm.Size.Width-10) (maxForm.Size.Height-80)
		btnRefresh.location = dotNetObject "System.Drawing.Point" 74 (maxForm.Size.Height-75)
	),
	
	handlerR = dotNet.addEventHandler maxForm "Resize" (fn f contol arg = struct_guiForm.resizeFrm control arg),

	-- CellValueChanged
	
	fn CVCH control arg = (
		
		/*
		print("Column caption = "+arg.Column.Caption)
		print("Column AbsoluteIndex = "+arg.Column.AbsoluteIndex as string)
		print("Node Id = "+arg.Node.Id as string) -- номер строки
		print("Value = "+arg.Value as string)
		print("Selected Rows Number = "+tl.Selection.Count as string)
		*/
		
		for i=0 to (tl.Selection.Count-1) do (
			tl.Selection.Item[i].SetValue arg.Column.AbsoluteIndex arg.Value
			--print("to object " + inTreeObj[tl.Selection.Item[i].Id].name + " set " + arg.Column.Caption + " to " + arg.Value as string)
			-- запись Uer Defined Properties
			case of (
			(arg.Column.Caption=="Export") : Param="msaExport"
			(arg.Column.Caption=="Anim Link") : Param="msaExportLink"
			(arg.Column.Caption=="Anim Morph") : Param="msaExportMorph"
			(arg.Column.Caption=="Texture") : Param="msaExportTex"
			(arg.Column.Caption=="Copy texture") : Param="msaExportCopyTex"
			(arg.Column.Caption=="Start frame") : Param="msaExportRangeStart"
			(arg.Column.Caption=="End frame") : Param="msaExportRangeEnd"
			default: Param=undefined
			)
			if Param!=undefined then(
				if tl.Selection.Item[i].Id ==0 then (
						for j=1 to inTreeObj.count do (
							setUserProp inTreeObj[j] Param arg.Value
						)
						addTargetNamesToEtl tl
						tl.Nodes.Item[0].SetValue arg.Column.AbsoluteIndex arg.Value
						
					)
				else setUserProp inTreeObj[tl.Selection.Item[i].Id] Param arg.Value
			)
		)
		
	),
	
	handlerCVCH = dotNet.addEventHandler tl "CellValueChanged" (fn f contol arg = struct_guiForm.CVCH control arg),

	fn VCh control arg = (
		tl.PostEditor()
	),
	handlerCh = dotNet.addEventHandler riCheck "EditValueChanged" (fn f contol arg = struct_guiForm.VCh control arg),
	fn RefreshPressed control arg = (
		addTargetNamesToEtl tl
	),
	handlerbR = dotNet.addEventHandler btnRefresh "Click" (fn f contol arg = struct_guiForm.RefreshPressed control arg)
)

struct_guiForm = struct_guiForm()
--clearListener()