//Relat�rio Folha S8 (EFET)
#INCLUDE "TOPCONN.CH"  
#INCLUDE "PROTHEUS.CH"  

User Function NWESTR01() 
Local oReport
Local aPar		:= {}
Local aMes		:= {"Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro","Todos"}
Local cArqTrb 	:= GetNextAlias()

Private cTitulo	:= "Relatorio de Folha S8(EFET)"
Private aRet	:= {} 

aAdd(aPar,{1,"Qual o Ano"			,Space(04),"","","","",0,.T.})		// Tipo caractere
aAdd(aPar,{2,"Qual o M�s"			,Nil,aMes,40,"",.T.})				// Tipo Combo
aAdd(aPar,{1,"Tipos de Produto"		,Space(15),"","","02","",0,.F.})	// Tipo caractere


If ParamBox(aPar,cTitulo,@aRet, , , , , , ,ProcName(),.T., .T.)
	Processa( {|| RunProc(cArqTrb,aMes,aRet) },cTitulo,"Gerando arquivo tempor�rio de trabalho",.F.)
	oReport := ReportDef(cArqTrb)
	oReport:PrintDialog()
Endif

If Select(cArqTrb) > 0
	(cArqTrb)->(DbCloseArea())
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RunProc   �Autor  �TOTVS               � Data �  21/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento do relatorio                                  ���
�������������������������������������������������������������������������͹��
���Uso       � NESTLE WATERS                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�������������������������������������������������������������������������͹��
���Altera��o �Inclusao das novas partes do custo Nestle                   ���
�������������������������������������������������������������������������͹��
   Altera��o realizada por Eduardo Ramos  no programa NWESTR01.PRW em 12/12/13
Inclus�o das Partes 07,08,09,10,11 e 99

�����������������������������������������������������������������������������
*/

Static Function RunProc(cArqTrb,aMes,aRet)

Local cPeriod := aRet[1]+IIF(aRet[2]=="Todos","%",StrZero(aScan(aMes,{|x| AllTrim(x) == AllTrim(aRet[2])}),2)+"%")
Local aGrpIni := StrTokArr(AllTrim(aRet[3]),",") 
Local cWhere  := "%AND SD3.D3_CF LIKE 'PR%' AND SD3.D3_ESTORNO = ''%"  
Local cGrpIni := ""
Local x

For x:=1 To Len(aGrpIni)
	cGrpIni += aGrpIni[x]+"','"
Next

cGrpIni := SubStr(cGrpIni,1,Len(cGrpIni)-3)

BeginSql Alias cArqTrb 
	SELECT * FROM (
		        SELECT '1' TIPO, AUX1.D3_FILIAL, AUX1.D3_COD, AUX1.B1_DESC, AUX1.D3_TIPO, 
				AUX1.D3_QTSEGUM, 
				AUX1.D3_QUANT,
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0101/AUX1.D3_QUANT,8) END D3_CP0101,
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0201/AUX1.D3_QUANT,8) END D3_CP0201,
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0301/AUX1.D3_QUANT,8) END D3_CP0301,
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0401/AUX1.D3_QUANT,8) END D3_CP0401,
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0501/AUX1.D3_QUANT,8) END D3_CP0501, 
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0601/AUX1.D3_QUANT,8) END D3_CP0601,

//inclus�o de novas partes de produtos 

								CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0701/AUX1.D3_QUANT,8) END D3_CP0701,
								CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0801/AUX1.D3_QUANT,8) END D3_CP0801,
								CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP0901/AUX1.D3_QUANT,8) END D3_CP0901,
								CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP1001/AUX1.D3_QUANT,8) END D3_CP1001,								
								CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP1101/AUX1.D3_QUANT,8) END D3_CP1101,				
								CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CP9901/AUX1.D3_QUANT,8) END D3_CP9901,				
// Final da Altera��o
				CASE AUX1.D3_QUANT WHEN 0 THEN 0 ELSE ROUND(AUX1.D3_CUSTO1/AUX1.D3_QUANT,8) END D3_CUSTO1
				FROM (
						SELECT  D3_FILIAL, D3_COD, B1_DESC, D3_TIPO, 
							SUM(ROUND(D3_QTSEGUM,8)) D3_QTSEGUM, 
							SUM(ROUND(D3_QUANT,8)) D3_QUANT,
							SUM(ROUND(D3_CP0101,8)) D3_CP0101,
							SUM(ROUND(D3_CP0201,8)) D3_CP0201,
							SUM(ROUND(D3_CP0301,8)) D3_CP0301,
							SUM(ROUND(D3_CP0401,8)) D3_CP0401,
							SUM(ROUND(D3_CP0501,8)) D3_CP0501, 
							SUM(ROUND(D3_CP0601,8)) D3_CP0601,
// inclus�o de novas partes
							SUM(ROUND(D3_CP0701,8)) D3_CP0701,
							SUM(ROUND(D3_CP0801,8)) D3_CP0801,
							SUM(ROUND(D3_CP0901,8)) D3_CP0901,
							SUM(ROUND(D3_CP1001,8)) D3_CP1001,
							SUM(ROUND(D3_CP1101,8)) D3_CP1101,							
							SUM(ROUND(D3_CP9901,8)) D3_CP9901,							
// Final da Altera��o
							SUM(ROUND(D3_CUSTO1,8)) D3_CUSTO1
						FROM %table:SD3% SD3
						INNER JOIN %table:SB1% SB1
							ON SB1.B1_FILIAL = %xFilial:SB1%
							AND SB1.B1_COD = SD3.D3_COD
							AND SB1.%notdel%
						WHERE SD3.%notdel%
							AND SD3.D3_FILIAL = %xFilial:SD3%
							%Exp:cWhere%							
							AND SD3.D3_EMISSAO LIKE %Exp:cPeriod%
							AND SD3.D3_TIPO IN (%Exp:cGrpIni%) 
					GROUP BY SD3.D3_FILIAL, SD3.D3_COD, SB1.B1_DESC, SD3.D3_TIPO
					) AUX1
		
		UNION ALL
		
		SELECT '2' TIPO, D3_FILIAL, D3_COD, B1_DESC, D3_TIPO, 
				SUM(ROUND(D3_QTSEGUM,2)) D3_QTSEGUM, 
				SUM(ROUND(D3_QUANT,2))  D3_QUANT,
				SUM(ROUND(D3_CP0101,2)) D3_CP0101,
				SUM(ROUND(D3_CP0201,2)) D3_CP0201,
				SUM(ROUND(D3_CP0301,2)) D3_CP0301,
				SUM(ROUND(D3_CP0401,2)) D3_CP0401,
				SUM(ROUND(D3_CP0501,2)) D3_CP0501, 
				SUM(ROUND(D3_CP0601,2)) D3_CP0601,
// inclus�o de novas partes no custo 
				SUM(ROUND(D3_CP0701,2)) D3_CP0701,				
				SUM(ROUND(D3_CP0801,2)) D3_CP0801,				
				SUM(ROUND(D3_CP0901,2)) D3_CP0901,				
				SUM(ROUND(D3_CP1001,2)) D3_CP1001,				
				SUM(ROUND(D3_CP1101,2)) D3_CP1101,				
				SUM(ROUND(D3_CP9901,2)) D3_CP9901,				
// Final da Altera��o
				SUM(ROUND(D3_CUSTO1,2)) D3_CUSTO1
			FROM %table:SD3% SD3
			INNER JOIN %table:SB1% SB1
				ON SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = SD3.D3_COD
				AND SB1.%notdel%
			WHERE SD3.%notdel%
				AND SD3.D3_FILIAL = %xFilial:SD3%
				%Exp:cWhere%
				AND SD3.D3_EMISSAO LIKE %Exp:cPeriod%
				AND SD3.D3_TIPO IN (%Exp:cGrpIni%) 
		GROUP BY SD3.D3_FILIAL, SD3.D3_COD, SB1.B1_DESC, SD3.D3_TIPO
		) TMP
	ORDER BY TMP.D3_FILIAL, TMP.D3_COD, TMP.TIPO
EndSql 

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Microsiga           � Data �    /  /     ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������͹��
���Alter��o  � Fun��o alterada por Eduardo Ramos     � Data �  12/12/2013 ���
�������������������������������������������������������������������������ͼ��
inclus�o de novas partes para o custo da Nestle

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportDef(cArqTrb)
Local oReport
Local oSecIts
Local oBreak
Local cRpFont := 'Courier New'
Local nRpFont := 8   //=====> Para incluir as novas partes precisa Verificar se o tamanho das fontes atender� o tamanho do Formul�rio "S8"

cTitulo += "  PERIODO "+aRet[2]+" / "+aRet[1]

//New(cReport,cTitle,uParam,bAction,cDescription,lLandscape,uTotalText,lTotalInLine,cPageTText,lPageTInLine,lTPageBreak,nColSpace)
oReport := TReport():New("NWESTR01",cTitulo,"",{ |oReport| ReportPrint(oReport,cArqTrb)},"Imprimi a Folha S8",.T.,"Custo Total",.F.)   

oReport:cFontBody 	:= cRpFont
oReport:nFontBody 	:= nRpFont
oReport:nLineHeight := (nRpFont*5) //Define o Tamanho da linha em fun��o da fonte, multiplica por 5 para manter a porpor��o em pixel.
 
//New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
oSecIts:= TRSection():New(oReport,"MOVIMENTOS",cArqTrb)//,,,,,,,,,,,,,.F.)
                                  
//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
//TRCell():New(oSecIts,"D3_FILIAL" ,cArqTrb,"Filial"	 	,,oReport:Char2Pix(TamSx3("D3_FILIAL")[1]	,cRpFont,nRpFont))
TRCell():New(oSecIts,"D3_COD"	 ,cArqTrb,"C�digo"	 		)//,,oReport:Char2Pix(TamSx3("D3_COD")[1]		,cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"B1_DESC"	 ,cArqTrb,"Descri��o"		)//,,oReport:Char2Pix(TamSx3("B1_DESC")[1]		,cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_TIPO"	 ,cArqTrb,"Tipo"	 		)//,,oReport:Char2Pix(TamSx3("D3_GRUPO")[1]	,cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_QTSEGUM",cArqTrb,"Qtd. Litros"		)//,,oReport:Char2Pix(TamSx3("D3_QTSEGUM")[1]	,cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_QUANT"	 ,cArqTrb,"Qtd. Pack"		)//,,oReport:Char2Pix(TamSx3("D3_QUANT")[1]	,cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_CP0101" ,cArqTrb,"Pre�o M.Prima"	)//,,oReport:Char2Pix(TamSx3("D3_CP0101")[1]+TamSx3("D3_CP0101")[2],cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_CP0201" ,cArqTrb,"Pre�o M.Embal." 	)//,,oReport:Char2Pix(TamSx3("D3_CP0201")[1]+TamSx3("D3_CP0201")[2],cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_CP0301" ,cArqTrb,"Custo Vari�vel" 	)//,,oReport:Char2Pix(TamSx3("D3_CP0301")[1]+TamSx3("D3_CP0301")[2],cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_CP0401" ,cArqTrb,"Custo Fixo"	 	)//,,oReport:Char2Pix(TamSx3("D3_CP0401")[1]+TamSx3("D3_CP0401")[2],cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_CP0501" ,cArqTrb,"Custo Deprec."   )//,,oReport:Char2Pix(TamSx3("D3_CP0501")[1]+TamSx3("D3_CP0501")[2],cRpFont,nRpFont),.T.)
TRCell():New(oSecIts,"D3_CP0601" ,cArqTrb,"Custo parte 6"	)//Ajustado,,oReport:Char2Pix(TamSx3("D3_CP0601")[1]+TamSx3("D3_CP0601")[2],cRpFont,nRpFont),.T.)

// inclus�o de novas colunas para apresenta��o das partes  no relat�rio: Sr. Andr� Pestana deve acertar o texto de cada coluna com nome real
TRCell():New(oSecIts,"D3_CP0701" ,cArqTrb,"Custo parte 7"	)//custo em parte incluido
TRCell():New(oSecIts,"D3_CP0801" ,cArqTrb,"Custo parte 8"	)//custo em parte incluido
TRCell():New(oSecIts,"D3_CP0901" ,cArqTrb,"Custo parte 9"	)//custo em parte incluido
TRCell():New(oSecIts,"D3_CP1001" ,cArqTrb,"Custo parte 10"	)//custo em parte incluido
TRCell():New(oSecIts,"D3_CP1101" ,cArqTrb,"Custo parte 11"	)//custo em parte incluido
TRCell():New(oSecIts,"D3_CP9901" ,cArqTrb,"Custo Outros"	)//custo em parte incluido


TRCell():New(oSecIts,"D3_CUSTO1" ,cArqTrb,"Total"			)//,IIF((cArqTrb)->TIPO == "1","@E 9,999,999,999.99999","@E 999,999,999,999.999"))//oReport:Char2Pix(TamSx3("D3_CUSTO1")[1]+TamSx3("D3_CUSTO1")[2],cRpFont,nRpFont),.T.)


//New(oParent,uBreak,uTitle,lTotalInLine,cName,lPageBreak)
//oBreak := TRBreak():New(oSecIts,oSecIts:Cell("D3_QTSEGUM"),"Total Geral",.F.)

//New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)
TRFunction():New(oSecIts:Cell("D3_QTSEGUM")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_QUANT")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_CP0101")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_CP0201")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_CP0301")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_CP0401")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_CP0501")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
TRFunction():New(oSecIts:Cell("D3_CP0601")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
// inclus�o so novos custos
TRFunction():New(oSecIts:Cell("D3_CP0701")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})//custo em parte incluido
TRFunction():New(oSecIts:Cell("D3_CP0801")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})//custo em parte incluido
TRFunction():New(oSecIts:Cell("D3_CP0901")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})//custo em parte incluido
TRFunction():New(oSecIts:Cell("D3_CP1001")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})//custo em parte incluido
TRFunction():New(oSecIts:Cell("D3_CP1101")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})//custo em parte incluido
TRFunction():New(oSecIts:Cell("D3_CP9901")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})//custo em parte incluido
// final da Altera��o 
TRFunction():New(oSecIts:Cell("D3_CUSTO1")	,,"SUM",,"",,,.F.,.T.,.F.,oSecIts,{|| (cArqTrb)->TIPO == "2"})
 

Return(oReport)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint�Autor  �Microsiga           � Data �  10/11/11   ���
��������������������������������������������������������������������������͹��
���Desc.     �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport,cArqTrb)
Local oSecIts := oReport:Section(1)

oReport:SetMeter((cArqTrb)->(RecCount()))
oSecIts:Init()

While (cArqTrb)->(!Eof())
	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()
	
	If (cArqTrb)->TIPO == "1"
		oSecIts:Cell("D3_COD"):Show()
		oSecIts:Cell("B1_DESC"):Show()
		oSecIts:Cell("D3_TIPO"):Show()
		oSecIts:Cell("D3_QTSEGUM"):Show()
		oSecIts:Cell("D3_QUANT"):Show()
	Else
		oSecIts:Cell("D3_COD"):Hide()
		oSecIts:Cell("B1_DESC"):Hide()
		oSecIts:Cell("D3_TIPO"):Hide()
		oSecIts:Cell("D3_QTSEGUM"):Hide()
		oSecIts:Cell("D3_QUANT"):Hide()
	EndIf
	
	oSecIts:PrintLine()

	(cArqTrb)->(dbSkip())
EndDo

oSecIts:Finish()

	
Return oReport