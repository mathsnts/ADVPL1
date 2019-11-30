//----------------------------------------------------------------------------------------------------------------//
// Demonstracao do Do Case...EndCase.
// Do Case...EndCase --> avalia a partir do primeiro Case.
//                       Ao encontrar o primeiro que satisfa�a,
//                       a condi�ao, executa e vai para o EndCase.
//----------------------------------------------------------------------------------------------------------------//

User Function TstCase()

Local nOpc := 2


Do Case
   Case nOpc == 1
        MsgAlert("Op��o 1 selecionada")
   Case nOpc == 2
        MsgAlert("Op��o 2 selecionada")
   Case nOpc == 3
        MsgAlert("Op��o 3 selecionada")
   Otherwise
        // Otherwise � opcional.
        MsgAlert("Nenhuma op��o selecionada")
EndCase

Return


/*

Do Case
   Case Clima == "CHUVOSO"
        LEVAR GUARDA-CHUVA
   Case Temperatura == "FRIO"
        LEVAR AGASALHO
EndCase

Se estiver chovendo e quente?
Se estiver ensolarado e frio?
Se estiver chovendo e frio?

*/