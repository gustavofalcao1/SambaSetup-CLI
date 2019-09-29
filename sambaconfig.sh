#!/bin/bash

x="teste"

menu ()
{
while true $x != "teste"
do
clear
echo "=============================================================================================="
echo "                                   CONFIGURAÇÃO DO SAMBA"
echo "=============================================================================================="
echo ""
echo "------------------------------------------"
echo "    Instalar / Atualizar SAMBA  - 1"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Adicionar Novo Usúario      - 2"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Remover Usúario             - 3"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Adicionar Novo Grupo        - 4"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Remover Grupo               - 5"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Add Usúario ao  Grupo       - 6"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Add Usúario ao SAMBA        - 7"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Criar servidor SAMBA        - 8"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Sair                        - 0"
echo "------------------------------------------"
echo ""
echo "Informe a opção desejada: "
read x
echo ""
echo "Opção informada ($x)"
echo "=============================================================================================="
echo ""
echo "=============================================================================================="

case "$x" in


    1)
      echo "Instalando / Atualizando todos os pacotes do SAMBA..."
      echo ""
      sudo apt install samba libcups2 samba samba-common cups -y
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    2)
      echo "Informe o nome do Usúario que deseja criar: "
      read useradd
      echo ""
      sudo adduser --no-create-home $useradd
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    3)
      echo "Informe o nome do Usúario que deseja deletar: "
      read userdel
      echo ""
      echo "O Usúario $userdel e todo seus arquivos serão Eliminados. Tem certeza? "
      echo "<ENTER> p/ Continuar ou <CTRL+C> p/ Cancelar e Sair: "
      read #pause
      echo ""
      sudo userdel -r $userdel
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    4)
      echo "Informe o nome do Grupo que deseja criar: "
      read groupadd
      echo ""
      sudo groupadd $groupadd
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    5)
      echo "Informe o nome do Grupo que deseja remover: "
      read groupdel
      echo "O Grupo $groupdel e todo seus arquivos serão Eliminados. Tem certeza? "
      echo "<ENTER> p/ Continuar ou <CTRL+C> p/ Cancelar e Sair: "
      read #pause
      echo ""
      sudo groupdel $groupdel
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    6)
      echo "Informe o Grupo: "
      read group
      echo ""
      echo "Informe o Usúario que deseja adicionar a $group: "
      read user
      echo ""
      sudo addgroup $user $group
      echo ""
      echo "SUCESSO!!!"
      sleep 2

echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    7)
      echo "Informe o Usúario que deja adicionar ao SAMBA: "
      read $usersamba
      echo ""
      sudo smbpasswd -a $usersamba
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    8)
      cp /etc/samba/smb.conf /etc/samba/smb.conf.bk 
      echo "Informe o Nome do servidor SAMBA: "
      read nomeserver
      echo ""
      echo "Informe um comentário (ou deixe em branco) para o servidor SAMBA: "
      read comment
      echo ""
      echo "Informe o diretório para o servidor SAMBA Ex.:(/home/server): "
      read path
      echo ""
      echo "Informe se o diretório pode ser aberto: [yes] p/ Sim ou [no] p/ Não"
      read browsable
      echo ""
      echo "Informe se os arquivos são apenas para leitura: [yes] p/ Sim ou [no] p/ Não"
      read readon
      echo ""
      echo "Informe se o servidor permite Usúarios sem credencias: [yes] p/ Sim ou [no] p/ Não"
      read guest
      echo ""
      echo "Informe o Usúario / Grupo que tem permissão de acessar esté server: "
      read valid
      echo ""
      sudo echo "
        [$nomeserver]
        comment = $comment
        path = $path
        browseable = $browsable
        read only = $readon
        guest ok = $guest
        valid users = @$valid
      " >> /etc/samba/smb.conf
      echo ""
      echo "SUCESSO!!!"
      sleep 2
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    0)
      echo "Saindo..."
      sudo /etc/init.d/smbd restart
      sleep 2
      clear;
      exit;
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;

*)
        echo "Opção inválida!"
esac
done

}
menu
