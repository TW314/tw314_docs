DROP PROCEDURE IF EXISTS tw314.PRC_GERAR_TICKET;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PRC_GERAR_TICKET`( IN  P_EMPRESA_ID 	   		INT    ,
																IN  P_SERVICO_ID 	   		INT    ,
																IN  P_PRIORIDADE 			INT	   ,
																OUT P_CODIGO_ACESSO		VARCHAR(20),
																OUT P_TICKET			VARCHAR(20),
																OUT P_CODIGO				INT	   ,
																OUT P_MENSAGEM			VARCHAR(255))
BEGIN
	DECLARE C_EMPRESA			INT	    ;
	DECLARE C_SERVICO			INT	    ;
	DECLARE C_SERVICO_VINC		INT	    ;
	DECLARE C_TICKET			INT	    ;
	DECLARE C_SIGLA				INT	    ;
	DECLARE V_NR_TICKET 		INT     ;
	DECLARE V_ULTIMO_TICKET		INT	    ;
	DECLARE V_SIGLA_SERVICO VARCHAR (10);
    DECLARE V_CODIGO_ACESSO VARCHAR(255);
    

	IF (P_EMPRESA_ID IS NOT NULL && P_SERVICO_ID IS NOT NULL && P_PRIORIDADE IS NOT NULL) THEN
		START TRANSACTION;
			SELECT COUNT(*)
			  INTO C_EMPRESA
			  FROM empresa
			 WHERE id = P_EMPRESA_ID
			   AND status_ativacao = 'Ativo';

			IF (C_EMPRESA = 1) THEN
				SELECT COUNT(*)
				  INTO C_SERVICO
				  FROM servico
				 WHERE id = P_SERVICO_ID
				   AND status_ativacao = 'Ativo';

				IF (C_SERVICO = 1) THEN
					SELECT COUNT(*)
					  INTO C_SERVICO_VINC
					  FROM relacionamento_emp_svc
					 WHERE empresaId = P_EMPRESA_ID
					   AND servicoId = P_SERVICO_ID;

					IF (C_SERVICO_VINC = 1) THEN
						SELECT sigla
						  INTO V_SIGLA_SERVICO
						  FROM servico
						 WHERE id = P_SERVICO_ID
						   AND status_ativacao = 'Ativo';

						IF (V_SIGLA_SERVICO IS NOT NULL) THEN
							SELECT COUNT(*)
							  INTO C_TICKET
							  FROM ticket
							 WHERE empresaId = P_EMPRESA_ID
							   AND servicoId = P_SERVICO_ID
							   AND DATE(data_hora_emissao) = DATE(SYSDATE());

							IF (C_TICKET = 0) THEN
								SET V_NR_TICKET = 001;
							ELSE
								SELECT MAX(NUMERO_TICKET)
								  INTO V_ULTIMO_TICKET
								  FROM ticket
								 WHERE empresaId = P_EMPRESA_ID
								   AND servicoId = P_SERVICO_ID
								   AND DATE(data_hora_emissao) = DATE(SYSDATE());

								SET V_NR_TICKET = V_ULTIMO_TICKET + 1;
							END IF;
                            
                            SELECT CONCAT(P_EMPRESA_ID, DATE_FORMAT(SYSDATE(), '%Y%m%d'), V_SIGLA_SERVICO, V_NR_TICKET, P_SERVICO_ID)
                              INTO V_CODIGO_ACESSO;
						
							INSERT INTO ticket
							VALUES (-- CODIGO DE ACESSO EH FORMADO PELO IDEMPRESA + DATA + SIGLA + NUMERO TICKET SENDO GERADO + IDSERVICO
									/*
									 * PEDRO 2016-10-26 TODO: CRIPTOGRAFAR CODIGO DE ACESSO E REDUZIR NUMERO DE CARACTERES
									 */
									V_CODIGO_ACESSO,
									NULL, V_NR_TICKET, SYSDATE(), SYSDATE(), SYSDATE()
									, P_PRIORIDADE, 1, P_EMPRESA_ID, P_SERVICO_ID
									);
							COMMIT;
							
							CALL PRC_FILA_SEQUENCIAL (V_CODIGO_ACESSO, @CODIGO, @MENSAGEM);
                            
                            IF (@CODIGO <> 0) THEN
								SELECT @CODIGO, @MENSAGEM
                                  INTO P_CODIGO, P_MENSAGEM;
                            END IF;
							
							SELECT codigo_acesso, CONCAT(V_SIGLA_SERVICO, numero_ticket), 0, 'Sucesso'
							  INTO P_CODIGO_ACESSO, P_TICKET, P_CODIGO, P_MENSAGEM
							  FROM ticket
							 WHERE codigo_acesso = V_CODIGO_ACESSO;
						ELSE
							SELECT 100, 'Erro: Sigla do Serviço está vazia no sistema. Realizando rollback das alterações.'
							  INTO P_CODIGO, P_MENSAGEM;
							ROLLBACK;
						END IF;
					-- FIM DA TRANSACAO
					ELSE
						SELECT 3, 'Erro: Serviço não está vinculado nesta empresa. Realizando rollback das alterações.'
						  INTO P_CODIGO, P_MENSAGEM;
						ROLLBACK;
					END IF;
				ELSE
					SELECT 2, 'Erro: Serviço não existe ou está inativo no sistema. Realizando rollback das alterações.'
					  INTO P_CODIGO, P_MENSAGEM;
					ROLLBACK;
				END IF;
			ELSE
				SELECT 1, 'Erro: Empresa está inativa no sistema. Realizando rollback das alterações.'
				  INTO P_CODIGO, P_MENSAGEM;
				ROLLBACK;
			END IF;
		ELSE
			SELECT -1, 'Erro: Parâmetro de entrada vazio. Realizando rollback das transacões.'
			  INTO P_CODIGO, P_MENSAGEM;
		ROLLBACK;
	END IF;
END;
