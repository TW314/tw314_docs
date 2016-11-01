USE `tw314`;
DROP procedure IF EXISTS `PRC_GERAR_TICKET`;

DELIMITER $$
USE `tw314`$$
CREATE PROCEDURE `PRC_GERAR_TICKET`( IN  P_EMPRESA_ID 	   		INT,
									 IN  P_SERVICO_ID 	   		INT,
									 IN  P_PRIORITARIO 		BOOLEAN)
BEGIN
	DECLARE C_EMPRESA			INT	   ;
    DECLARE C_SERVICO			INT	   ;
    DECLARE C_SERVICO_VINC		INT	   ;
    DECLARE C_TICKET			INT	   ;
    DECLARE C_SIGLA				INT	   ;
    DECLARE V_NR_TICKET 		INT    ;
    DECLARE V_ULTIMO_TICKET		INT	   ;
    DECLARE V_SIGLA_SERVICO VARCHAR(10);
    
    IF (P_EMPRESA_ID IS NOT NULL && P_SERVICO_ID IS NOT NULL && P_PRIORIDADE IS NOT NULL) THEN
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
				   AND servicoId = P_SERVICO_ID
                   AND status_ativacao = 'Ativo';
				
                IF (C_SERVICO_VINC = 1) THEN
                	START TRANSACTION;
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
							
							INSERT INTO TICKET
							VALUES (-- CODIGO DE ACESSO EH FORMADO PELO IDEMPRESA + DATA + SIGLA + NUMERO TICKET SENDO GERADO + IDSERVICO
									/*
									 * PEDRO 2016-10-26 TODO: CRIPTOGRAFAR CODIGO DE ACESSO E REDUZIR NUMERO DE CARACTERES
									 */
									CONCAT(P_EMPRESA_ID, DATE_FORMAT(SYSDATE(), '%Y%m%d'), V_SIGLA_SERVICO, V_NR_TICKET, P_SERVICO_ID), 
                                    NULL, V_NR_TICKET, SYSDATE(), SYSDATE(), SYSDATE(), P_PRIORIDADE, 1, P_EMPRESA_ID, P_SERVICO_ID);
							COMMIT;
						
							SELECT codigo_acesso, CONCAT(V_SIGLA_SERVICO, numero_ticket), 0, 'Sucesso'
							  INTO P_CODIGO_ACESSO, P_TICKET, P_CODIGO, P_MENSAGEM
							  FROM ticket
						     WHERE codigo_acesso = CONCAT(P_EMPRESA_ID, DATE_FORMAT(SYSDATE(), '%Y%m%d'), V_SIGLA_SERVICO, V_NR_TICKET, P_SERVICO_ID);
						ELSE
							ROLLBACK;
						END IF;
					-- FIM DA TRANSACAO
                ELSE
					ROLLBACK;
                END IF;
            ELSE
				ROLLBACK;
            END IF;
        ELSE
			ROLLBACK;
        END IF;
    ELSE
		ROLLBACK;
	END IF;
END$$

DELIMITER ;