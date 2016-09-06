show columns from home_perfil;
insert into home_status values
	(1,'ativo','Ativado'),
    (2,'inativo','Inativado')
;
select * from home_status;

show columns from home_perfil;
insert into home_perfil values
	(0, "Suporte", "Administra o sistema geral. Cadastra Estabelecimento, Serviços, Ramos de Atividades e Administrador"),
	(0, "Administrador", "Administra o sistema local. Cadastra Funcionários e vincula serviços"),
	(0, "Funcionário", "Faz o atendimento")
;
select * from home_perfil;