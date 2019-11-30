#Include "rwmake.ch"

User Function Oper()

Local x                           // Declara vari�veis inicialmente com valor nulo.
Local y
Local nRenda, nImposto 
Local xVariavel                  

xVariavel := "Agora a vari�vel � caracter..."
MsgAlert("Valor do Texto: " + xVariavel)

xVariavel := 22                   // Agora a vari�vel � num�rica.
MsgAlert(cValToChar(xVariavel))

xVariavel := .T.                  // Agora a vari�vel � l�gica.
If xVariavel
   MsgAlert("A vari�vel tem valor verdadeiro...")
Else                                                  
   MsgAlert("A vari�vel tem valor falso..")
EndIf

xVariavel := CtoD("10/10/04")     // Agora a vari�vel � data.
MsgAlert("Hoje �: " + DtoC(xVariavel))
 
xVariavel := Nil                  // Nulo novamente.
MsgAlert("Valor nulo: NIL")

// Simples soma.
x := 2
y := 5
y := x + y
MsgAlert("Resultado: " + Str(y))
 
a := 2
b := 4
c := a + b
MsgAlert(c)

MsgAlert("C elevado a 2: " + Str(c**2))
 
// Calcula Imposto sem dialogo.
nRenda   := 3000
nImposto := 0

Do Case
   Case nRenda < 1000
        nImposto  := 0
   Case nRenda < 2000
        nImposto  := (nRenda - 1000) * 0.10
   Otherwise
        nImposto  := ((nRenda - 2000) * 0.20) + 100
EndCase

MsgAlert("Valor a Pagar: " + Str(nImposto ))

Return Nil	 
                