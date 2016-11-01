drop database tw314;
create database tw314;
use tw314;
show tables;
desc ticket;

select * from perfil;
select * from status_ticket;
select * from ramo_atividade;
select * from empresa;
select * from servico;
select * from relacionamento_emp_svc;
select * from ticket;
select * from usuario;

desc ticket;

insert into perfil(nome, descricao, createdAt, updatedAt) value('Suporte','Perfil de Suporte', sysdate(), sysdate());
insert into perfil(nome, descricao, createdAt, updatedAt) value('Administrador','Perfil de Administrador', sysdate(), sysdate());
insert into perfil(nome, descricao, createdAt, updatedAt) value('Funcionario','Perfil de Funcionario', sysdate(), sysdate());
insert into status_ticket(nome, descricao, createdAt, updatedAt) values('Aguardando Atendimento','Ainda não foi atendido', sysdate(), sysdate());
insert into status_ticket(nome, descricao, createdAt, updatedAt) values('Em atendimento','Esta em atendimento', sysdate(), sysdate());
insert into status_ticket(nome, descricao, createdAt, updatedAt) values('Concluido','Ja foi atendido', sysdate(), sysdate());
insert into status_ticket(nome, descricao, createdAt, updatedAt) values('Cancelado','Não compareceu ou desistencia do atendimento', sysdate(), sysdate());
insert into prioridade_ticket(nome, descricao, createdAt, updatedAt) values ('Prioritario', 'Ticket que passa na frente', SYSDATE(), SYSDATE());
insert into prioridade_ticket(nome, descricao, createdAt, updatedAt) values ('Normal', 'Ticket que fica para tras', SYSDATE(), SYSDATE());
insert into ramo_atividade(nome, descricao, status_ativacao, createdAt, updatedAt) values('Financeiro','Faz contas', 'Ativo', sysdate(), sysdate());
insert into empresa(nome_fantasia, razao_social, numero_cnpj, logradouro, numero_logradouro, cidade, uf, cep, pais, telefone, email, nome_responsavel, cargo_responsavel, cpf_responsavel, data_abertura, data_ativacao, status_ativacao, ramoAtividadeId, createdAt, updatedAt) values('TW314', 'TW314', '12345678912345', 'logradouro', 'numero_logradouro', 'Guaratingueta', 'SP', '12518160', 'Brasil', '12345678912', 'teste@teste.com', 'Alan', 'Algum', '123', sysdate(), sysdate(), 'Ativo', 1, sysdate(), sysdate());
insert into servico(nome, descricao, sigla, status_ativacao, createdAt, updatedAt, ramoAtividadeId) values('Contabilidade', 'Faz contas', 'CB', 'Ativo', sysdate(), sysdate(), 1);
insert into relacionamento_emp_svc(status_ativacao, createdAt, updatedAt, empresaId, servicoId) values('Ativo', sysdate(), sysdate(), 1, 1);
insert into ticket(numero_ticket, data_hora_emissao, codigo_acesso, createdAt, updatedAt, statusTicketId, empresaId, servicoId, prioridadeTicketId) values(314, sysdate(), CONCAT(DATE_FORMAT(SYSDATE(), '%Y%m%d'),'tw314'), sysdate(), sysdate(), 1, 1, 1, 1);
insert into usuario(nome, email, data_ativacao, senha, data_inativacao, status_ativacao, createdAt, updatedAt, empresaId, perfilId) values('Alan', 'alan@alan.com', sysdate(), '123', sysdate(), 'Ativo', sysdate(), sysdate(), 1, 2);
insert into usuario(nome, email, data_ativacao, senha, data_inativacao, status_ativacao, createdAt, updatedAt, empresaId, perfilId) values('Halu', 'halu@halu.com', sysdate(), '123', sysdate(), 'Ativo', sysdate(), sysdate(), 1, 2);
insert into usuario(nome, email, data_ativacao, senha, data_inativacao, status_ativacao, createdAt, updatedAt, empresaId, perfilId) values('Pedro', 'pedro@pedro.com', sysdate(), '123', sysdate(), 'Ativo', sysdate(), sysdate(), 1, 2);

CALL PRC_GERAR_TICKET (1, 1, 2, @codigo_ticket, @ticket, @codigo, @mensagem);
CALL PRC_FILA_SEQUENCIAL ('120161101CB3201', @codigo, @mensagem);

SELECT @ticket, @codigo_ticket, @codigo, @mensagem;

SELECT * FROM TICKET ORDER BY 4 DESC;

UPDATE TICKET
   SET numero_sequencial = 1;

SELECT *
  FROM status_ticket;