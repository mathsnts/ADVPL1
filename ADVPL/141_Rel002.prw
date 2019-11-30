
// Rotina de relatorio que imprime o extrato de contas-correntes.
// Similar ao REL001, porem, utilizando os dois arquivos: SZ1 e SZ2.

User Function Rel002()

Local cAlias   := ""                                  // Alias do arquivo a ser impresso.
Local cNomeArq := FunName()                           // Nome do arquivo a ser gerado caso a impressao seja em disco.
Local wnRel                                           // Retorno da fun��o SetPrint().
// Descricao do relatorio.
Local cDesc1   := "Este programa imprime o extrato das contas-correntes de todas as Contas."
Local cDesc2   := ""
Local cDesc3   := ""

Private cTitulo   := "Extrato de Contas-Correntes"     // Titulo do relatorio.
Private cCabec1   := "  Data    Tipo Mov           Valor           Saldo"
Private cCabec2   := ""
Private cNomeProg := FunName()                        // Nome do programa no cabecalho do relatorio.
Private cTamanho  := "P"                              // Tamanho do relatorio.
Private nTipo                                         // Relatorio normal ou comprimido.
Private m_Pag     := 1                                // Numero da pagina.

// O array aReturn � usado pela fun��o SetPrint(). Define o formato, tipo de impressao e o nome do arquivo.
// aReturn[1] = Reservado para formulario
// aReturn[2] = Reservado para numero de vias
// aReturn[3] = Destinatario
// aReturn[4] = Formato: 1-Retrato, 2-Paisagem
// aReturn[5] = Tipo midia: 1-Disco, 2-Via spool, 3-Direto na porta, 4-EMail
// aReturn[6] = "NomeArq"-Disco, "LPT1"-Via spool, "LPT1"-Direto na porta, ""-Cancelado
// aReturn[7] = Expressao do filtro
// aReturn[8] = Ordem a ser selecionada
Private aReturn := {"Zebrado", 1,"Administracao", 1, 1, "CANCELADO", "", 1}

// Fun��o SetPrint(): prepara os parametros para a impressao do relatorio.
// Parametros:
//    cAlias   --> Alias do arquivo a ser listado. Se passado, apresenta as op��es de sele��o dos campos
//                 a imprimir (Dicionario de Dados) e defini��o de um filtro.
//    cNomeArq --> Nome do arquivo a ser gerado caso selecione a op��o de impress�o em disco.
//    cPerg    --> Codigo do conjunto de perguntas (parametros). Caso seja passado, permite apresentar o
//                 conjunto de perguntas.
//    cTitulo  --> Titulo do relatorio.
//    cDesc1   --> Descri��o do relatorio.
//    cDesc2   --> Descri��o do relatorio.
//    cDesc3   --> Descri��o do relatorio.
//    lDic     --> .T. apresenta o Dicionario de Dados para sele��o dos campos a imprimir. .F. nao apresenta.
//    aOrd     --> Array com as ordens de impressao.
//    lCompres --> .T. comprimido. .F. normal.
//    cSize    --> Tamanho do relatorio: "P"-80 col., "M"-132 col., "G"-220 col.
//
// Retorna para a variavel wnRel o nome do arquivo a ser gerado, caso a impressao seja em disco.

wnRel := SetPrint(cAlias, cNomeArq, , @cTitulo, cDesc1, cDesc2, cDesc3, .F., , .F., cTamanho)

// Define se o relatorio � normal ou comprimido.
nTipo := IIf(aReturn[4] == 1, 15, 18)

// Se na fun��o SetPrint() foi clicado o botao Cancelar, ou seja, abortou a emiss�o do relatorio,
// o sexto elemento do vetor aReturn conter� "CANCELADO".
If aReturn[6] <> "CANCELADO"           // Nao cancelou o relatorio.
   // Prepara a impressora ou o arquivo para receber o relatorio.
   // Estabelece os campos a serem impressos e o filtro, caso tenham sido definidos.
   SetDefault(aReturn, cAlias)
   // Executa a rotina de impressao do relatorio.
   RptStatus({|lFim| Imprime(@lFim)}, "Aguarde...", "Imprimindo o extrato...")
   // Envia o relatorio para o spool ou exibe na tela, dependendo da op��o selecionada.
   OurSpool(wnRel)
EndIf

MS_Flush()                             // Libera a memoria.

Return Nil

//----------------------------------------------------------------------------------------------------------------// 
// Rotina de impress�o do relatorio.
//----------------------------------------------------------------------------------------------------------------// 
Static Function Imprime(lFim)

Local nValor
Local nSaldo

dbSelectArea("SZ1")          // Seleciona o Cadastro de Contas.
dbOrderNickName("NOME")      // Seleciona a chave "Filial + Nome".
dbGoTop()                    // Vai para o primeiro registro, de acordo com a ordem selecionada.

SetRegua(RecCount())         // Inicializa a regua.

While !SZ1->(Eof())          // Executa a sequencia de comandos enquanto nao for Fim de Arquivo.

   IncRegua()                // Incrementa a regua.

   If lFim
      @PRow()+2,000 PSay "*** CANCELADO PELO USUARIO ***"
      Exit
   EndIf

   If PRow() > 60            // Se o "cursor" da impressora ultrapassou 60 linhas,
      Eject                  // salta para a pagina seguinte e
      SetPrc(0, 0)           // zera o "cursor" da impressora.
   EndIf

   If PRow() == 0            // Se o "cursor" da impressora estiver no inicio de uma nova pagina,
      Cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo)  // imprime o cabe�alho.
   EndIf

   // Para cada Conta, deve haver uma separa��o e o seu nome deve aparecer antes da listagem de suas transa��es.
   // E tamb�m o seu saldo deve ser inicializado.

   @PRow()+1,000 PSay __PrtThinLine()              // Imprime uma linha para separar a Conta anterior.
   @PRow()+1,000 PSay "Nome: " + SZ1->Z1_Nome      // Imprime o nome da nova Conta.
   @PRow()+1,000 PSay " "                          // Pula uma linha em branco.

   nSaldo := 0                                     // Inicializa o saldo.

   dbSelectArea("SZ2")
   dbOrderNickName("NOME_NR_IT")
   dbSeek(xFilial("SZ2") + SZ1->Z1_Nome)

   While !SZ2->(Eof()) .And. SZ2->Z2_Nome == SZ1->Z1_Nome

      If PRow() > 60         // Se o "cursor" da impressora ultrapassou 60 linhas,
         Eject               // salta para a pagina seguinte e
         SetPrc(0, 0)        // zera o "cursor" da impressora.
      EndIf

      If PRow() == 0         // Se o "cursor" da impressora estiver no inicio de uma nova pagina,
         Cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo)  // imprime o cabe�alho.
      EndIf

      @PRow()+1,000      PSay SZ2->Z2_Data                                   // Imprime a Data.
      @PRow()  ,PCol()+2 PSay IIf(SZ2->Z2_Tipo=="D", "Deposito", "Saque   ") // Imprime a descri��o do Tipo de Transa��o.

      // Se o Tipo de Transa��o for SAQUE, transforma o valor para negativo.
      nValor := SZ2->Z2_Valor * IIf(SZ2->Z2_Tipo=="D", 1, -1)

      // Acumula o saldo.
      nSaldo += nValor

      @PRow()  ,PCol()+2 PSay nValor Picture "@E 999,999,999.99"             // Imprime o Valor.
      @PRow()  ,PCol()+2 PSay nSaldo Picture "@E 999,999,999.99"             // Imprime o Saldo.

      SZ2->(dbSkip())

   End

   dbSelectArea("SZ1")
   SZ1->(dbSkip())        // Vai para o proximo registro, tambem pela ordem selecionada.

End

// Imprime uma linha final, ap�s a ultima Conta listada.
@PRow()+1,000 PSay __PrtThinLine()

Return Nil         // Termina a fun��o, retornando ao ponto onde foi chamada. N�o retorna nenhum valor.
