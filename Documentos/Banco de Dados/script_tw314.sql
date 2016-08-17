-- MySQL Workbench Synchronization
-- Generated: 2016-07-28 19:17
-- Model: New Model
-- Version: 1.0
-- Project: Name of the project
-- Author: Pedro

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `tw314` DEFAULT CHARACTER SET utf8 ;

CREATE TABLE IF NOT EXISTS `tw314`.`Empresa` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificação da Empresa no sistema.',
  `nome_fantasia` VARCHAR(80) NOT NULL COMMENT 'Nome da Empresa.',
  `razao_social` VARCHAR(80) NOT NULL,
  `nr_cnpj` VARCHAR(14) NOT NULL COMMENT 'Número de CNPJ da Empresa.',
  `logradouro` VARCHAR(255) NOT NULL COMMENT 'Logradouro onde se localiza a Empresa.',
  `nr_logradouro` VARCHAR(5) NOT NULL COMMENT 'Número do Prédio da Empresa.',
  `cidade` VARCHAR(100) NOT NULL COMMENT 'Cidade onde se localiza a Empresa.',
  `uf` VARCHAR(2) NOT NULL COMMENT 'Unidade da Federação onde se localiza a cidade da Empresa.',
  `bairro` VARCHAR(100) NOT NULL COMMENT 'País em que se localiza a Empresa.',
  `cep` VARCHAR(8) NOT NULL,
  `dt_abertura` DATE NOT NULL COMMENT 'Data de Abertura da Empresa.',
  `ramo_atividade_id` INT(11) NOT NULL COMMENT 'Ramo de Atividade da Empresa.',
  `telefone` VARCHAR(11) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `dt_ativacao` DATE NOT NULL COMMENT 'Data de Ativação da Empresa no sistema.',
  `dt_inativacao` DATE NULL DEFAULT NULL COMMENT 'Data de Inativação da Empresa no sistema.',
  `status_id` INT(11) NOT NULL COMMENT 'Identificação do Status de ativação da Empresa. Pode ser A - ATIVO ou I - INATIVO.',
  `nome_responsavel` VARCHAR(80) NOT NULL COMMENT 'Nome do Responsável pela Empresa no sistema.',
  `cargo_responsavel` VARCHAR(45) NOT NULL COMMENT 'Cargo do responsável pela Empresa no sistema.',
  `cpf_responsavel` VARCHAR(11) NOT NULL COMMENT 'Número de CPF da pessoa responsável pela Empresa no sistema.',
  PRIMARY KEY (`id`),
  INDEX `fkStatusEmpresa_idx` (`status_id` ASC),
  INDEX `fkRamoAtividadeEmpresa_idx` (`ramo_atividade_id` ASC),
  CONSTRAINT `FK_STS_EMP`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_RMO_EMP`
    FOREIGN KEY (`ramo_atividade_id`)
    REFERENCES `tw314`.`RamoAtividade` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Servico` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificação do Serviço no sistema.',
  `sigla` VARCHAR(2) NOT NULL COMMENT 'Sigla significativa do Serviço, para o ato de geraro Ticket.',
  `nome` VARCHAR(45) NOT NULL COMMENT 'Nome do Serviço no sistema.',
  `descricao` VARCHAR(255) NOT NULL COMMENT 'Breve descrição do Serviço.',
  `ramo_atividade_id` INT(11) NOT NULL COMMENT 'Identificação do Ramo de Atividade do Serviço.',
  `status_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fkRamoAtividadeServico_idx` (`ramo_atividade_id` ASC),
  INDEX `fkStatusServico_idx` (`status_id` ASC),
  CONSTRAINT `FK_RMO_SVC`
    FOREIGN KEY (`ramo_atividade_id`)
    REFERENCES `tw314`.`RamoAtividade` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Servico_Status1`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Perfil` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificação do Perfil na Empresa. Pode ser 0, 1 ou 2.',
  `nome` VARCHAR(45) NOT NULL COMMENT 'Nome do Perfil no sistema.\nPode ser:\n0-Suporte\n1-Administrador.\n2-Funcionário.',
  `descricao` VARCHAR(255) NOT NULL COMMENT 'Breve descrição das permissões do Perfil.',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Usuario` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificação do Usuário no sistema.',
  `empresa_id` INT(11) NOT NULL COMMENT 'Identificação da Empresa empregadora do Usuário.',
  `nome` VARCHAR(80) NOT NULL COMMENT 'Nome do Usuário.',
  `perfil_id` INT(11) NOT NULL COMMENT 'Identificação de Perfil do Usuário. Pode ser 1 - Administrador ou 2 - Funcionário.',
  `dt_ativacao` DATE NOT NULL COMMENT 'Data de ativação do Usuário no sistema.',
  `dt_inativacao` DATE NULL DEFAULT NULL COMMENT 'Data de inativação do Usuário no sistema.',
  `status_id` INT(11) NOT NULL COMMENT 'Identificação de Ativação do Usuário. Pode ser: A - ATIVO ou I - INATIVO.',
  `email` VARCHAR(100) NOT NULL,
  `senha` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fkEmpresaUsuario_idx` (`empresa_id` ASC),
  INDEX `fkPerfilUsuario_idx` (`perfil_id` ASC),
  INDEX `fkStatusUsuario_idx` (`status_id` ASC),
  UNIQUE INDEX `uqEmail` (`email` ASC),
  CONSTRAINT `FK_EMP_USU`
    FOREIGN KEY (`empresa_id`)
    REFERENCES `tw314`.`Empresa` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_PFL_USU`
    FOREIGN KEY (`perfil_id`)
    REFERENCES `tw314`.`Perfil` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_STS_USU`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Ticket` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificação numérica do Ticket.',
  `nr_ticket` INT(11) NOT NULL,
  `servico_id` INT(11) NOT NULL COMMENT 'Identificação dos Serviços no Ticket.',
  `empresa_id` INT(11) NOT NULL COMMENT 'Identificação da Empresa onde Ticket foi emitido.',
  `data_hora_emissao` DATETIME NOT NULL COMMENT 'Data de emissão do Ticket.',
  `cd_acesso` VARCHAR(8) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fkRelacionamentoTicket_idx` (`empresa_id` ASC, `servico_id` ASC),
  UNIQUE INDEX `uqTicket` (`servico_id` ASC, `empresa_id` ASC, `data_hora_emissao` ASC, `nr_ticket` ASC),
  UNIQUE INDEX `uqCdAcesso` (`cd_acesso` ASC),
  CONSTRAINT `FK_EMP_SVC_TCK_EMP_ID`
    FOREIGN KEY (`empresa_id` , `servico_id`)
    REFERENCES `tw314`.`RelacionamentoEmpresaServico` (`empresa_id` , `servico_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Atendimento` (
  `ticket_id` INT(11) NOT NULL COMMENT 'Identificação do Ticket de solicitação do Atendimento.',
  `usuario_id` INT(11) NOT NULL COMMENT 'Identificação do Usuário realizando o Atendimento.',
  `data_hora_inicio` DATETIME NOT NULL COMMENT 'Data de início do Atendimento.',
  `data_hora_fim` DATETIME NULL DEFAULT NULL COMMENT 'Data de fim do Atendimento.',
  `status_id` INT(11) NOT NULL COMMENT 'Identificação do Status do Andamento do Atendimento.',
  INDEX `fkUsuarioAtendimento_idx` (`usuario_id` ASC),
  PRIMARY KEY (`ticket_id`),
  INDEX `fkTicketAtendimento_idx` (`ticket_id` ASC),
  INDEX `fkStatusAtendimendo_idx` (`status_id` ASC),
  CONSTRAINT `FK_USU_ATD`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `tw314`.`Usuario` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_TCK_ATD`
    FOREIGN KEY (`ticket_id`)
    REFERENCES `tw314`.`Ticket` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_STS_ATD`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`RelacionamentoEmpresaServico` (
  `empresa_id` INT(11) NOT NULL COMMENT 'Identificação da Empresa no Relacionamento',
  `servico_id` INT(11) NOT NULL COMMENT 'Identificação do Serviço no Relacionamento',
  `status_id` INT(11) NOT NULL COMMENT 'Identificação do Status de Ativação do Serviço na Empresa.',
  PRIMARY KEY (`empresa_id`, `servico_id`),
  INDEX `fkServicoRelacionamento_idx` (`servico_id` ASC),
  INDEX `fkEmpresaRelacionamento_idx` (`empresa_id` ASC),
  INDEX `fkStatusRelacionamento_idx` (`status_id` ASC),
  CONSTRAINT `FK_EMP_REL`
    FOREIGN KEY (`empresa_id`)
    REFERENCES `tw314`.`Empresa` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_SVC_REL`
    FOREIGN KEY (`servico_id`)
    REFERENCES `tw314`.`Servico` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_STS_REL`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Status` (
  `id` INT(11) NOT NULL COMMENT 'Identificação do Status de ativação/andamento.',
  `nome` VARCHAR(45) NOT NULL COMMENT 'Nome do status de ativação/andamento.',
  `descricao` VARCHAR(255) NOT NULL COMMENT 'Descrição de uso do status de ativação/andamento.',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`RamoAtividade` (
  `id` INT(11) NOT NULL COMMENT 'Identificação do Ramo de Atividade',
  `nome` VARCHAR(45) NOT NULL COMMENT 'Nome do Ramo de Atividade.',
  `status_id` INT(11) NOT NULL COMMENT 'Identificação do Status do Ramo',
  PRIMARY KEY (`id`),
  INDEX `fkStatusRamoAtividade_idx` (`status_id` ASC),
  CONSTRAINT `FK_STS_RAMO`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `tw314`.`Chamado` (
  `id` INT(11) NOT NULL COMMENT 'Identificação do Chamado',
  `usuario_id_abertura` INT(11) NOT NULL COMMENT 'Identificação do Usuário que abriu o Chamado.',
  `data_abertura` DATE NOT NULL COMMENT 'Data de abertura do Chamado.',
  `status_id` INT(11) NOT NULL COMMENT 'Identificação do Status do Chamado.',
  `usuario_id_resposta` INT(11) NULL DEFAULT NULL,
  `data_atualizacao` DATE NULL DEFAULT NULL COMMENT 'Data de Atualização do Chamado.',
  `assunto` VARCHAR(100) NOT NULL COMMENT 'Assunto do Chamado.',
  `mensagem` VARCHAR(255) NOT NULL COMMENT 'Mensagem do Chamado.',
  PRIMARY KEY (`id`),
  INDEX `fkUsuarioChamado_idx` (`usuario_id_abertura` ASC, `usuario_id_resposta` ASC),
  INDEX `fkStatusChamado_idx` (`status_id` ASC),
  CONSTRAINT `FK_USU_CHA`
    FOREIGN KEY (`usuario_id_abertura` , `usuario_id_resposta`)
    REFERENCES `tw314`.`Usuario` (`id` , `id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_STS_CHA`
    FOREIGN KEY (`status_id`)
    REFERENCES `tw314`.`Status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
