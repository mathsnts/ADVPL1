#Include "PROTHEUS.CH"
/*_______________________________________________________________________________
���������������������������������������������������������������������������������
��+-----------+------------+-------+----------------------+------+------------+��
��� Programa  � Consulta   � Autor � Robson Luiz          � Data � 01/06/2002 ���
��+-----------+------------+-------+----------------------+------+------------+��
��� Descri��o � Demostracao da utiliza��o da fun�ao ListBox                   ���
��+-----------+---------------------------------------------------------------+��
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function Consult()

// Declara vari�veis com escopo LOCAL (vis�veis somente dentro da fun��o em que foi criada).
Local aArea  := GetArea()              // Tipo: Array      Conteudo: posi��o do arquivo atualmente selecionado.
Local aArray := {}                     // Tipo: Array      Conteudo: nome e saldo das contas para ser mostrados na tela.
Local oDlg                             // Tipo: Objeto     Conteudo: caixa de dialogo (janela).
Local oLbx                             // Tipo: Objeto     Conteudo: caixa de listagem (List Box).

dbSelectArea("SZ1")                    // Seleciona o arquivo de Contas.
dbOrderNickName("NOME")                // Seleciona a chave primaria: Z1_Filial + Z1_Nome.
dbGoTop()                              // Vai para o primeiro registro, de acordo com a ordem selecionada.

While !EOF()                           // Executar a sequencia de comandos ENQUANTO nao for Fim de Arquivo (End Of File, ou EOF).

   // Inicialmanete, a array estar� vazia.
   // A cada registro lido do arquivo, adiciona-se uma nova linha contendo duas colunas: Nome e Saldo da Conta.
   AAdd(aArray, {SZ1->Z1_Nome, SZ1->Z1_Saldo})

   dbSkip()                            // Vai para o proximo registro, tambem pela ordem selecionada.

End                                    // Saida do comando While.

// Se nao tiver nenhuma Conta cadastradao, a array permanecera vazia e, neste caso, nao havera o que ser mostrado na tela.
// Entao, deve-se verificar se o tamanho da array � maior do que zero, ou seja, se nao � uma array vazia.
If Len(aArray) > 0

   // Define a janela onde serao exibidos a Caixa de Listabem (ListBox) e os bot�es.
   Define MSDialog oDlg Title "Consulta" From 000,000 To 240,500 Pixel

   // Define o ListBox:

   @010,010 ListBox oLbx;                        // Posi��o inicial, dentro da janela, e o nome do objeto.
                    Fields;                      // Campos do arquivo (caso esteja listando diretamente algum arquivo).
                    Header "Nome", "Saldo";      // Cabe�alho das colunas.
                    Size 230,095 Pixel;          // Tamanho do ListBox, em pixels.
                    Of oDlg                      // Associa o ListBox � janela.

   oLbx:SetArray(aArray)                         // Define a array que sera a fonte dos dados a ser mostrados.

   oLbx:bLine := {|| {aArray[oLbx:nAt,1],;       // Define os dados a ser mostrados.
                      aArray[oLbx:nAt,2];
                     }}

   oLbx:bLDblClick := {|| u_Extrato(oLbx)}       // Define a a�ao que devera ser executada ao dar duplo-clique numa linha.
	                    
   // Cria um botao que chama a rotina de exibicao do extrato de conta-corrente
   // e outro que fecha a janela, encerrando a rotina de consulta.
   @107,160 Button "Ver Extrato" Size 40,12 Pixel Action u_Extrato(oLbx) Of oDlg
   @107,200 Button "Sair"        Size 40,12 Pixel Action oDlg:End()      Of oDlg

   Activate MSDialog oDlg Center                 // Desenha a janela, centralizando na tela.

 Else

   // Caso nao exista nenhuma Conta cadastrada, mostra um aviso.

   MsgAlert("Nao existem Contas a consultar!", "Aten��o!")

Endif

RestArea(aArea)    // Retorna ao arquivo que estava selecionado anteriormente.

Return Nil         // Termino da fun��o. N�o retorna nenhum valor.

/*_______________________________________________________________________________
���������������������������������������������������������������������������������
��+-----------+------------+-------+----------------------+------+------------+��
��� Programa  � Extrato    � Autor �                      � Data � 04/01/2005 ���
��+-----------+------------+-------+----------------------+------+------------+��
��� Descri��o � Lista o extrato de conta-corrente           .                 ���
��+-----------+---------------------------------------------------------------+��
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function Extrato(oLbx)

// Declara vari�veis com escopo LOCAL (vis�veis somente dentro da fun��o em que foi criada).
Local aArea := GetArea()               // Tipo: Array      Conteudo: posi��o do arquivo atualmente selecionado.
Local oDlg                             // Tipo: Objeto     Conteudo: caixa de dialogo (janela).
Local oLbxExt                          // Tipo: Objeto     Conteudo: caixa de listagem (List Box).
Local cNome                            // Tipo: Caracter   Conteudo: Nome da Conta selecionada.
Local aExtrato                         // Tipo: Array      Conteudo: Transa��es da Conta selecionada.
Local i

cNome    := oLbx:aArray[oLbx:nAt, 1]   // Obtem o nome da Conta atraves da array do ListBox, na linha selecionada, coluna 1.
aExtrato := {}                         // Inicializa a array.

dbSelectArea("SZ2")                    // Seleciona o arquivo de Transa��es.
dbOrderNickName("NOME_NR_IT")          // Seleciona a chave: Z2_Filial + Z2_Nome + Z2_Numero + Z2_Item.
dbSeek(xFilial() + cNome)              // Posiciona no primeiro registro da Conta selecionada.

// Executa a sequencia de comandos ENQUANTO for a mesma Conta e nao for Fim de Arquivo.
While SZ2->Z2_Nome == cNome .And. !EOF()

   // Adiciona uma nova linha na array, contendo as seguintes colunas:
   AAdd(aExtrato, {SZ2->Z2_Data                                 ,;   // Data da transa��o.
                   IIf(SZ2->Z2_Tipo=="D", "Dep�sito", "Saque")  ,;   // Se Tipo for D, "Dep�sito". Senao, "Saque".
                   SZ2->Z2_Valor * IIf(SZ2->Z2_Tipo=="D", 1, -1),;   // Se Tipo for D, o proprio valor. Senao, o valor X -1.
                   0                                             ;   // Coluna vazia, que contera o saldo que sera calculado.
                  })

   dbSkip()                            // Vai para proximo registro, pela ordem selecionada.

End

// Se a Conta selecionada nao tem nenhuma transa��o, o array sera vazio e nao havera dados a ser mostrados.
// Entao, deve-se verificar se o tamanho do array � maior do que zero, ou seja, se nao � umo array vazio.
If Len(aExtrato) > 0

   // Coloca o array em ordem de Nome (coluna 1).
   ASort(aExtrato, , , {|x,y| x[1] < y[1]})

   // Calcula o saldo di�rio de conta-corrente e coloca na coluna 5 da array.

   nSaldo := 0                         // Inicializa a variavel do saldo.

   // Executa a sequencia de comandos tantas vezes for a quantidade de linhas contidas na array.
   // A cada ciclo, incrementa 1 na variavel "i", ate a quantidade de linhas.
   For i := 1 To Len(aExtrato)
       nSaldo += aExtrato[i, 3]        // Soma em nSaldo o valor da coluna 4 desta linha da array (valor da transa��o).
       aExtrato[i, 4] := nSaldo        // Coloca na coluna 5 desta linha da array, o saldo calculado.
   Next

   // Define a janela onde serao exibidos a Caixa de Listabem (ListBox) e os bot�es.
   Define MSDialog oDlg Title "Extrato: " + cNome From 000,000 To 350,600 Pixel

   // Define o ListBox:

   @010,010 ListBox oLbxExt;                     // Posi��o inicial, dentro da janela, e o nome do objeto.
                    Fields;                      // Campos do arquivo (caso esteja listando diretamente algum arquivo).
                    Header "Data", "Tipo Mov.", "Valor", "Saldo";      // Cabe�alho das colunas.
                    Size 280,150 Pixel;          // Tamanho do ListBox, em pixels.
                    Of oDlg                      // Associa o ListBox � janela.

   oLbxExt:SetArray(aExtrato)                    // Define a array que sera a fonte dos dados a ser mostrados.

   oLbxExt:bLine := {|| {aExtrato[oLbxExt:nAt,1],;    // Define os dados a ser mostrados.
	                     aExtrato[oLbxExt:nAt,2],;
	                     aExtrato[oLbxExt:nAt,3],;
	                     aExtrato[oLbxExt:nAt,4];
	                    }}
	                    
   // Cria um botao que fecha a janela, encerrando a rotina de extrato.
   @162,250 Button "Sair" Size 40,12 Pixel Action oDlg:End() Of oDlg

   Activate MSDialog oDlg Center                 // Desenha a janela, centralizando na tela.

 Else

   // Caso nao exista nenhuma transa��o desta Conta, mostra um aviso.

   MsgAlert("Nao existe transa��o desta Conta!", "Aten��o!")

Endif

RestArea(aArea)    // Retorna ao arquivo que estava selecionado anteriormente.

Return Nil         // Termina a fun��o, retornando ao ponto onde foi chamada. N�o retorna nenhum valor.
