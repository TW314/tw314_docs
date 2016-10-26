CREATE PROCEDURE `PRC_GERAR_TICKET`( IN  P_EMPRESA_ID 	   		INT    ,
																IN  P_SERVICO_ID 	   		INT    ,
																IN  P_PRIORITARIO 		BOOLEAN	   ,
															    OUT P_CODIGO_ACESSO		VARCHAR(15),
																OUT P_TICKET			VARCHAR(10),
																OUT P_CODIGO				INT	   ,
																OUT P_MENSAGEM			VARCHAR(255))
BEGIN
	DECLARE C_EMPRESA			INT	   ;
    DECLARE C_SERVICO			INT	   ;
    DECLARE C_SERVICO_VINC		INT	   ;
    DECLARE C_TICKET			INT	   ;
    DECLARE C_SIGLA				INT	   ;
    DECLARE V_NR_TICKET 		INT    ;
    DECLARE V_ULTIMO_TICKET		INT	   ;
    DECLARE V_PRIORIDADE	VARCHAR(11);
    DECLARE V_SIGLA_SERVICO VARCHAR(10);
    
    IF (P_EMPRESA_ID IS NOT NULL && P_SERVICO_ID IS NOT NULL && P_PRIORITARIO IS NOT NULL) THEN
		SELECT COUNT(*)
          INTO C_EMPRESA
		  FROM EMPRESA
		 WHERE ID = P_EMPRESA_ID
           AND STATUS_ATIVACAO = 'Ativo';
		
        IF (C_EMPRESA > 0) THEN
			SELECT COUNT(*)
			  INTO C_SERVICO
              FROM SERVICO
			 WHERE ID = P_SERVICO_ID
			   AND STATUS_ATIVACAO = 'Ativo';
               
			IF (C_SERVICO > 0) THEN
				SELECT COUNT(*)
				  INTO C_SERVICO_VINC
                  FROM RELACIONAMENTO_EMPRESA_SERVICO
				 WHERE EMPRESAID = P_EMPRESA_ID
				   AND SERVICOID = P_SERVICO_ID
                   AND STATUS_ATIVACAO = 'Ativo';
				
                IF (C_SERVICO_VINC > 0) THEN
                	START TRANSACTION;
						SELECT SIGLA
						  INTO V_SIGLA_SERVICO
						  FROM SERVICO
						 WHERE ID = P_SERVICO_ID
						   AND STATUS_ATIVACAO = 'Ativo';
						
                        IF (V_SIGLA_SERVICO IS NOT NULL) THEN
							SELECT COUNT(*)
							  INTO C_TICKET
							  FROM TICKET
							 WHERE EMPRESAID = P_EMPRESA_ID
							   AND SERVICOID = P_SERVICO_ID
							   AND DATE(DATA_HORA_EMISSAO) = DATE(SYSDATE());
							
							IF (C_TICKET = 0) THEN
								SET V_NR_TICKET = 001;
							ELSE            
								SELECT MAX(NUMERO_TICKET)
								  INTO V_ULTIMO_TICKET
								  FROM TICKET
								 WHERE EMPRESAID = P_EMPRESA_ID
								   AND SERVICOID = P_SERVICO_ID
								   AND DATE(DATA_HORA_EMISSAO) = DATE(SYSDATE());
								
								SET V_NR_TICKET = V_ULTIMO_TICKET + 1;
							END IF;
                        
							IF (P_PRIORITARIO) THEN
								SET V_PRIORIDADE := 'Prioritario';
							ELSE
								SET V_PRIORIDADE := 'Normal';
							END IF;
								
							INSERT INTO TICKET
							VALUES (-- CODIGO DE ACESSO EH FORMADO PELA DATA + SIGLA + NUMERO TICKET SENDO GERADO
									/*
									 * PEDRO 2016-10-26 TODO: CRIPTOGRAFAR CODIGO DE ACESSO E REDUZIR NUMERO DE CARACTERES
									 */
									CONCAT(DATE_FORMAT(SYSDATE(), '%Y%m%d'), V_SIGLA_SERVICO, V_NR_TICKET), 
									V_NR_TICKET, SYSDATE(), V_PRIORIDADE, SYSDATE(), SYSDATE(), 1, P_EMPRESA_ID, P_SERVICO_ID);
							COMMIT;
						
							SELECT CODIGO_ACESSO, CONCAT(V_SIGLA_SERVICO, NUMERO_TICKET), 0, 'Sucesso'
							  INTO P_CODIGO_ACESSO, P_TICKET, P_CODIGO, P_MENSAGEM
							  FROM TICKET
								 WHERE CODIGO_ACESSO = CONCAT(DATE_FORMAT(SYSDATE(), '%Y%m%d'), V_SIGLA_SERVICO, V_NR_TICKET);
						ELSE
							SELECT 100, 'Erro: Sigla do Serviço está vazia no sistema'
							  INTO P_CODIGO, P_MENSAGEM;
							ROLLBACK;
						END IF;
					-- FIM DA TRANSACAO
                ELSE
					SELECT 3, 'Erro: Serviço não está vinculado nesta empresa'
					  INTO P_CODIGO, P_MENSAGEM;
                END IF;
            ELSE
				SELECT 2, 'Erro: Serviço não existe ou está inativo no sistema'
				  INTO P_CODIGO, P_MENSAGEM;
            END IF;
        ELSE
			SELECT 1, 'Erro: Empresa está inativa no sistema'
			  INTO P_CODIGO, P_MENSAGEM;
        END IF;
    ELSE
		SELECT -1, 'Erro: Parâmetro de entrada vazio. Realizando rollback das transacões'
		  INTO P_CODIGO, P_MENSAGEM;
		ROLLBACK;
	END IF;
END