create sequence S_PERMISSIONS;

create sequence S_PERMISSION_GROUPS;

create sequence S_USER_GROUPS;

/*==============================================================*/
/* Table: ACTIVITIES                                            */
/*==============================================================*/
create table ACTIVITIES (
   ACTIVITY_ID          VARCHAR(255)         not null,
   NAME                 VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_ACTIVITIES primary key (ACTIVITY_ID)
);

/*==============================================================*/
/* Table: CONFLICTS                                             */
/*==============================================================*/
create table CONFLICTS (
   CONFLICT_ID          VARCHAR(255)         not null,
   ACTIVITY1            VARCHAR(255)         not null,
   ACTIVITY2            VARCHAR(255)         not null,
   NAME                 VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_CONFLICTS primary key (CONFLICT_ID)
);

/*==============================================================*/
/* Index: INDEX_10                                              */
/*==============================================================*/
create  index INDEX_10 on CONFLICTS (
ACTIVITY1
);

/*==============================================================*/
/* Index: INDEX_11                                              */
/*==============================================================*/
create  index INDEX_11 on CONFLICTS (
ACTIVITY2
);

/*==============================================================*/
/* Table: GROUPS                                                */
/*==============================================================*/
create table GROUPS (
   GROUP_ID             VARCHAR(255)         not null,
   NAME                 VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_GROUPS primary key (GROUP_ID)
);

/*==============================================================*/
/* Table: GROUPS_ACTIVITIES                                     */
/*==============================================================*/
create table GROUPS_ACTIVITIES (
   GROUP_ID             VARCHAR(255)         not null,
   ACTIVITY_ID          VARCHAR(255)         not null,
   COUNTER              INT                  not null default '1',
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_GROUPS_ACTIVITIES primary key (GROUP_ID, ACTIVITY_ID)
);

/*==============================================================*/
/* Table: GT_USERS                                              */
/*==============================================================*/
create table GT_USERS (
   ID                   SERIAL               not null,
   LOGIN                VARCHAR(255)         null,
   PASSWORD             VARCHAR(255)         null,
   ACTIVE               BOOL                 null default TRUE,
   INITIALIZED          BOOL                 not null default FALSE,
   constraint PK_GT_USERS primary key (ID)
);

INSERT INTO GT_USERS(id, login, password, active, initialized) VALUES (1, 'admin', MD5('sod_admin'), TRUE, TRUE);

/*==============================================================*/
/* Table: GROUPS_SOLUTIONS                                      */
/*==============================================================*/
create table GROUPS_SOLUTIONS (
   GROUP_ID             VARCHAR(255)         not null,
   CONFLICT_ID          VARCHAR(255)         not null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   REASON               TEXT                 not null,
   GT_USER_ID           INT                  not null,
   REASON_CREATED       TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_GROUPS_SOLUTIONS primary key (GROUP_ID, CONFLICT_ID)
);

/*==============================================================*/
/* Table: MODULES                                               */
/*==============================================================*/
create table MODULES (
   MODULE_ID            VARCHAR(255)         not null,
   NAME                 VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_MODULES primary key (MODULE_ID)
);

/*==============================================================*/
/* Table: TRANSACTIONS                                          */
/*==============================================================*/
create table TRANSACTIONS (
   TRANSACTION_ID       VARCHAR(255)         not null,
   ACTIVITY_ID          VARCHAR(255)         null,
   NAME                 VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_TRANSACTIONS primary key (TRANSACTION_ID)
);

/*==============================================================*/
/* Index: INDEX_9                                               */
/*==============================================================*/
create  index INDEX_9 on TRANSACTIONS (
ACTIVITY_ID
);

/*==============================================================*/
/* Table: GROUPS_TRANSACTIONS                                   */
/*==============================================================*/
create table GROUPS_TRANSACTIONS (
   GROUP_ID             VARCHAR(255)         not null,
   TRANSACTION_ID       VARCHAR(255)         not null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_GROUPS_TRANSACTIONS primary key (GROUP_ID, TRANSACTION_ID)
);

/*==============================================================*/
/* Index: INDEX_1                                               */
/*==============================================================*/
create  index INDEX_1 on GROUPS_TRANSACTIONS using HASH (
TRANSACTION_ID
);

/*==============================================================*/
/* Index: INDEX_2                                               */
/*==============================================================*/
create  index INDEX_2 on GROUPS_TRANSACTIONS using HASH (
GROUP_ID
);

/*==============================================================*/
/* Table: GT_PERMISSION_GROUPS                                  */
/*==============================================================*/
create table GT_PERMISSION_GROUPS (
   ID                   SERIAL not null,
   PERMISSION_GROUP     TEXT                 not null,
   constraint PK_GT_PERMISSION_GROUPS primary key (ID)
);

INSERT INTO GT_PERMISSION_GROUPS (id, permission_group) VALUES (1, 'Configurações');
INSERT INTO GT_PERMISSION_GROUPS (id, permission_group) VALUES (2, 'Definições');
INSERT INTO GT_PERMISSION_GROUPS (id, permission_group) VALUES (3, 'Ferramentas');
INSERT INTO GT_PERMISSION_GROUPS (id, permission_group) VALUES (4, 'Acompanhamento');
INSERT INTO GT_PERMISSION_GROUPS (id, permission_group) VALUES (5, 'Relatórios');

/*==============================================================*/
/* Table: GT_PERMISSIONS                                        */
/*==============================================================*/
create table GT_PERMISSIONS (
   ID                   SERIAL not null,
   PERMISSION           TEXT                 null,
   GROUP_ID             INT                  null,
   REFERENCE            TEXT                 null,
   READ_WRITE           BOOL                 null default TRUE,
   constraint PK_GT_PERMISSIONS primary key (ID)
);

INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Usuários', 1, 'config_usuarios', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Grupos de Permissões', 1, 'config_grupos_permissoes', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Trocar Senha de Terceiros', 1, 'config_usuarios_senha', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Grupos de Permissões', 1, 'config_lembretes', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Usuários', 2, 'definitions_users', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Grupos', 2, 'definitions_groups', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Transações', 2, 'definitions_transactions', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Transações', 2, 'definitions_modules', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Atividades', 2, 'definitions_activities', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Conflitos', 2, 'definitions_conflicts', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Exportar dados', 1, 'definitions_export_data', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Importar dados', 1, 'definitions_import_data', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Resumo', 5, 'reports_summary', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Distribuição de Usuários', 5, 'reports_users', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Distribuição de Grupos', 5, 'reports_groups', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Distribuição de Transações', 5, 'reports_transactions', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Distribuição de Atividades', 5, 'reports_activities', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Distribuição de Módulos', 5, 'reports_modules', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Distribuição de Conflitos', 5, 'reports_conflicts', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Acompanhamento', 4, 'dashboard', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Snapshots', 3, 'tools_snapshots', true);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Resolução de Conflitos', 3, 'tools_solve_conflicts', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Criar Grupos', 3, 'tools_create_groups', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Criar Usuários', 3, 'tools_create_users', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Relatório de Alterações', 3, 'tools_changelog', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Consolidação de dados', 3, 'tools_verify_data', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Consolidação de dados', 3, 'tools_my_access_demands', false);
INSERT INTO GT_PERMISSIONS (permission, group_id, reference, read_write) VALUES ('Consolidação de dados', 3, 'tools_access_demands', false);

/*==============================================================*/
/* Table: GT_USER_GROUPS                                        */
/*==============================================================*/
create table GT_USER_GROUPS (
   ID                   SERIAL not null,
   USER_GROUP           text                 null,
   DESCRIPTION          TEXT                 null,
   INITIALIZED          BOOL                 not null default FALSE,
   constraint PK_GT_USER_GROUPS primary key (ID)
);

/*==============================================================*/
/* Table: GT_GROUPS_PERMISSIONS                                 */
/*==============================================================*/
create table GT_GROUPS_PERMISSIONS (
   GROUP_ID             INT                  not null,
   PERMISSION           INT                  not null,
   VALUE                INT                  not null,
   constraint PK_GT_GROUPS_PERMISSIONS primary key (GROUP_ID, PERMISSION)
);

/*==============================================================*/
/* Table: GT_USERS_GROUPS                                       */
/*==============================================================*/
create table GT_USERS_GROUPS (
   USER_ID              INT                  not null,
   GROUP_ID             INT                  not null,
   constraint PK_GT_USERS_GROUPS primary key (USER_ID, GROUP_ID)
);

/*==============================================================*/
/* Table: GT_USERS_PERMISSIONS                                  */
/*==============================================================*/
create table GT_USERS_PERMISSIONS (
   USER_ID              INT                  not null,
   PERMISSION           INT                  not null,
   VALUE                INT                  not null,
   constraint PK_GT_USERS_PERMISSIONS primary key (USER_ID, PERMISSION)
);

INSERT INTO GT_USERS_PERMISSIONS(user_id, permission, value)
SELECT 1, id, 2 FROM GT_Permissions;

/*==============================================================*/
/* Table: JOURNAL                                               */
/*==============================================================*/
create table JOURNAL (
   JOURNAL_ID           SERIAL               not null,
   DESCRIPTION          TEXT                 not null,
   ENTRY_TYPE           VARCHAR(255)         not null,
   REFERENCE            VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null,
   constraint PK_JOURNAL primary key (JOURNAL_ID)
);

/*==============================================================*/
/* Table: LOG                                                   */
/*==============================================================*/
create table LOG (
   LOG_ID               SERIAL               not null,
   GT_USER_ID           INT4                 not null,
   OPERATION            varchar(255)         null,
   MODULE               varchar(255)         not null,
   DESCRIPTION          text                 not null,
   FORM                 varchar(255)         not null,
   CREATED              timestamp            not null default CURRENT_TIMESTAMP,
   constraint PK_LOG primary key (LOG_ID)
);

/*==============================================================*/
/* Table: MODULES_TRANSACTIONS                                  */
/*==============================================================*/
create table MODULES_TRANSACTIONS (
   MODULE_ID            VARCHAR(255)         not null,
   TRANSACTION_ID       VARCHAR(255)         not null,
   CREATED              timestamp            null default CURRENT_TIMESTAMP,
   constraint PK_MODULES_TRANSACTIONS primary key (TRANSACTION_ID, MODULE_ID)
);

/*==============================================================*/
/* Index: INDEX_7                                               */
/*==============================================================*/
create  index INDEX_7 on MODULES_TRANSACTIONS (
TRANSACTION_ID
);

/*==============================================================*/
/* Index: INDEX_8                                               */
/*==============================================================*/
create  index INDEX_8 on MODULES_TRANSACTIONS (
MODULE_ID
);

/*==============================================================*/
/* Table: SNAPSHOTS                                             */
/*==============================================================*/
create table SNAPSHOTS (
   SNAPSHOT_ID          SERIAL               not null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   USERS_CONFLICTS      INT                  not null default '0',
   ACCEPTED_USERS_CONFLICTS INT                  not null default '0',
   GROUPS_CONFLICTS     INT                  not null default '0',
   ACCEPTED_GROUPS_CONFLICTS INT                  not null default '0',
   constraint PK_SNAPSHOTS primary key (SNAPSHOT_ID)
);

/*==============================================================*/
/* Table: USERS                                                 */
/*==============================================================*/
create table USERS (
   USER_ID              VARCHAR(255)         not null,
   NAME                 VARCHAR(255)         null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_USERS primary key (USER_ID)
);

/*==============================================================*/
/* Table: USERS_ACTIVITIES                                      */
/*==============================================================*/
create table USERS_ACTIVITIES (
   USER_ID              VARCHAR(255)         not null,
   ACTIVITY_ID          VARCHAR(255)         not null,
   COUNTER              INT                  not null default '1',
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_USERS_ACTIVITIES primary key (USER_ID, ACTIVITY_ID)
);

/*==============================================================*/
/* Table: USERS_GROUPS                                          */
/*==============================================================*/
create table USERS_GROUPS (
   USER_ID              VARCHAR(255)         not null,
   GROUP_ID             VARCHAR(255)         not null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_USERS_GROUPS primary key (USER_ID, GROUP_ID)
);

/*==============================================================*/
/* Index: INDEX_5                                               */
/*==============================================================*/
create  index INDEX_5 on USERS_GROUPS using HASH (
USER_ID
);

/*==============================================================*/
/* Index: INDEX_6                                               */
/*==============================================================*/
create  index INDEX_6 on USERS_GROUPS using HASH (
GROUP_ID
);

/*==============================================================*/
/* Table: USERS_SOLUTIONS                                       */
/*==============================================================*/
create table USERS_SOLUTIONS (
   USER_ID              VARCHAR(255)         not null,
   CONFLICT_ID          VARCHAR(255)         not null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   REASON               TEXT                 not null,
   GT_USER_ID           INT                  not null,
   REASON_CREATED       TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_USERS_SOLUTIONS primary key (USER_ID, CONFLICT_ID)
);

/*==============================================================*/
/* Table: USERS_TRANSACTIONS                                    */
/*==============================================================*/
create table USERS_TRANSACTIONS (
   USER_ID              VARCHAR(255)         not null,
   TRANSACTION_ID       VARCHAR(255)         not null,
   CREATED              TIMESTAMP            not null default CURRENT_TIMESTAMP,
   constraint PK_USERS_TRANSACTIONS primary key (USER_ID, TRANSACTION_ID)
);

/*==============================================================*/
/* Index: INDEX_3                                               */
/*==============================================================*/
create  index INDEX_3 on USERS_TRANSACTIONS (
USER_ID
);

/*==============================================================*/
/* Index: INDEX_4                                               */
/*==============================================================*/
create  index INDEX_4 on USERS_TRANSACTIONS (
TRANSACTION_ID
);

alter table CONFLICTS
   add constraint FK_CONFLICT_REFERENCE_ACT1 foreign key (ACTIVITY1)
      references ACTIVITIES (ACTIVITY_ID)
      on delete restrict on update cascade;

alter table CONFLICTS
   add constraint FK_CONFLICT_REFERENCE_ACT2 foreign key (ACTIVITY2)
      references ACTIVITIES (ACTIVITY_ID)
      on delete restrict on update cascade;

alter table GROUPS_ACTIVITIES
   add constraint FK_GROUPS_A_REFERENCE_ACTIVITI foreign key (ACTIVITY_ID)
      references ACTIVITIES (ACTIVITY_ID)
      on delete cascade on update cascade;

alter table GROUPS_ACTIVITIES
   add constraint FK_GROUPS_A_REFERENCE_GROUPS foreign key (GROUP_ID)
      references GROUPS (GROUP_ID)
      on delete cascade on update cascade;

alter table GROUPS_SOLUTIONS
   add constraint FK_GROUPS_S_REFERENCE_GT_USERS foreign key (GT_USER_ID)
      references GT_USERS (ID)
      on delete restrict on update cascade;

alter table GROUPS_SOLUTIONS
   add constraint FK_GROUPS_S_REFERENCE_CONFLICT foreign key (CONFLICT_ID)
      references CONFLICTS (CONFLICT_ID)
      on delete cascade on update cascade;

alter table GROUPS_SOLUTIONS
   add constraint FK_GROUPS_S_REFERENCE_GROUPS foreign key (GROUP_ID)
      references GROUPS (GROUP_ID)
      on delete cascade on update cascade;

alter table GROUPS_TRANSACTIONS
   add constraint FK_GROUPS_T_REFERENCE_TRANSACT foreign key (TRANSACTION_ID)
      references TRANSACTIONS (TRANSACTION_ID)
      on delete restrict on update cascade;

alter table GROUPS_TRANSACTIONS
   add constraint FK_GROUPS_T_REFERENCE_GROUPS foreign key (GROUP_ID)
      references GROUPS (GROUP_ID)
      on delete restrict on update cascade;

alter table GT_GROUPS_PERMISSIONS
   add constraint FK_GT_GROUP_REFERENCE_GT_PERMI foreign key (PERMISSION)
      references GT_PERMISSIONS (ID)
      on delete restrict on update restrict;

alter table GT_GROUPS_PERMISSIONS
   add constraint FK_GT_GROUP_REFERENCE_GT_USER_ foreign key (GROUP_ID)
      references GT_USER_GROUPS (ID)
      on delete restrict on update restrict;

alter table GT_PERMISSIONS
   add constraint FK_GT_PERMI_REFERENCE_GT_PERMI foreign key (GROUP_ID)
      references GT_PERMISSION_GROUPS (ID)
      on delete restrict on update restrict;

alter table GT_USERS_GROUPS
   add constraint FK_GT_USERS_REFERENCE_GT_USERS foreign key (USER_ID)
      references GT_USERS (ID)
      on delete restrict on update restrict;

alter table GT_USERS_GROUPS
   add constraint FK_GT_USERS_REFERENCE_GT_USER_ foreign key (GROUP_ID)
      references GT_USER_GROUPS (ID)
      on delete restrict on update restrict;

alter table GT_USERS_PERMISSIONS
   add constraint FK_GT_USERS_REFERENCE_GT_USERS foreign key (USER_ID)
      references GT_USERS (ID)
      on delete restrict on update restrict;

alter table GT_USERS_PERMISSIONS
   add constraint FK_GT_USERS_REFERENCE_GT_PERMI foreign key (PERMISSION)
      references GT_PERMISSIONS (ID)
      on delete restrict on update restrict;

alter table LOG
   add constraint FK_LOG_REFERENCE_GT_USERS foreign key (GT_USER_ID)
      references GT_USERS (ID)
      on delete restrict on update restrict;

alter table MODULES_TRANSACTIONS
   add constraint FK_MODULES__REFERENCE_TRANSACT foreign key (TRANSACTION_ID)
      references TRANSACTIONS (TRANSACTION_ID)
      on delete restrict on update cascade;

alter table MODULES_TRANSACTIONS
   add constraint FK_MODULES__REFERENCE_MODULES foreign key (MODULE_ID)
      references MODULES (MODULE_ID)
      on delete restrict on update cascade;

alter table TRANSACTIONS
   add constraint FK_TRANSACT_REFERENCE_ACTIVITI foreign key (ACTIVITY_ID)
      references ACTIVITIES (ACTIVITY_ID)
      on delete set null on update cascade;

alter table USERS_ACTIVITIES
   add constraint FK_USERS_AC_REFERENCE_ACTIVITI foreign key (ACTIVITY_ID)
      references ACTIVITIES (ACTIVITY_ID)
      on delete cascade on update cascade;

alter table USERS_ACTIVITIES
   add constraint FK_USERS_AC_REFERENCE_USERS foreign key (USER_ID)
      references USERS (USER_ID)
      on delete cascade on update cascade;

alter table USERS_GROUPS
   add constraint FK_USERS_GR_REFERENCE_USERS foreign key (USER_ID)
      references USERS (USER_ID)
      on delete restrict on update cascade;

alter table USERS_GROUPS
   add constraint FK_USERS_GR_REFERENCE_GROUPS foreign key (GROUP_ID)
      references GROUPS (GROUP_ID)
      on delete restrict on update cascade;

alter table USERS_SOLUTIONS
   add constraint FK_USERS_SO_REFERENCE_GT_USERS foreign key (GT_USER_ID)
      references GT_USERS (ID)
      on delete restrict on update cascade;

alter table USERS_SOLUTIONS
   add constraint FK_USERS_SO_REFERENCE_CONFLICT foreign key (CONFLICT_ID)
      references CONFLICTS (CONFLICT_ID)
      on delete cascade on update cascade;

alter table USERS_SOLUTIONS
   add constraint FK_USERS_SO_REFERENCE_USERS foreign key (USER_ID)
      references USERS (USER_ID)
      on delete cascade on update cascade;

alter table USERS_TRANSACTIONS
   add constraint FK_USERS_TR_REFERENCE_USERS foreign key (USER_ID)
      references USERS (USER_ID)
      on delete restrict on update cascade;

alter table USERS_TRANSACTIONS
   add constraint FK_USERS_TR_REFERENCE_TRANSACT foreign key (TRANSACTION_ID)
      references TRANSACTIONS (TRANSACTION_ID)
      on delete restrict on update cascade;


CREATE OR REPLACE FUNCTION upsert_groups_activities (
  p_group_id varchar,
  p_activity_id varchar
)
RETURNS void AS
$body$
BEGIN
  INSERT INTO groups_activities(group_id, activity_id) VALUES (p_group_id, p_activity_id);
EXCEPTION
WHEN unique_violation THEN
  UPDATE groups_activities SET counter = counter + 1 WHERE group_id = p_group_id AND activity_id = p_activity_id;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;


CREATE OR REPLACE FUNCTION upsert_users_activities (
  p_user_id varchar,
  p_activity_id varchar
)
RETURNS void AS
$body$
BEGIN
  INSERT INTO users_activities(user_id, activity_id) VALUES (p_user_id, p_activity_id);
EXCEPTION
WHEN unique_violation THEN
  UPDATE users_activities SET counter = counter + 1 WHERE user_id = p_user_id AND activity_id = p_activity_id;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;


CREATE OR REPLACE FUNCTION clean_groups_activities_trg_fn (
)
RETURNS trigger AS
$body$
BEGIN
  DELETE FROM groups_activities WHERE counter = 0;
  RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

CREATE TRIGGER clean_groups_activities_trg
  AFTER UPDATE OF counter 
  ON groups_activities FOR EACH STATEMENT 
  EXECUTE PROCEDURE clean_groups_activities_trg_fn();


CREATE FUNCTION invalidate_users_and_groups_solutions_from_groups_transactions (
)
RETURNS trigger AS
$body$
DECLARE
    v_activity_id VARCHAR;
BEGIN
	-- Removendo os aceites de usuário que envolvem o grupo que está sendo modificado
	DELETE FROM users_solutions
	WHERE 
  		user_id IN (SELECT user_id FROM users_groups WHERE group_id = NEW.group_id)
		AND conflict_id IN (SELECT conflict_id
    						FROM conflicts
    						WHERE activity1 IN (SELECT activity_id FROM groups_activities WHERE group_id = NEW.group_id UNION SELECT activity_id FROM transactions WHERE transaction_id = NEW.transaction_id)
                	        	OR activity2 IN (SELECT activity_id FROM groups_activities WHERE group_id = NEW.group_id UNION SELECT activity_id FROM transactions WHERE transaction_id = NEW.transaction_id));

	-- Removendo os aceites de grupo que envolvem a nova transação
    SELECT activity_id FROM transactions INTO v_activity_id WHERE transaction_id = NEW.transaction_id;

	DELETE FROM groups_solutions
	WHERE 
		group_id = NEW.group_id
		AND conflict_id IN (SELECT conflict_id
    						FROM conflicts
    						WHERE activity1 = v_activity_id
                	        	OR activity2 = v_activity_id);
    RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;

CREATE TRIGGER groups_transactions_tr
  AFTER INSERT 
  ON public.groups_transactions FOR EACH ROW 
  EXECUTE PROCEDURE invalidate_users_and_groups_solutions_from_groups_transactions();


CREATE OR REPLACE FUNCTION public.update_groups_activities_fn (
)
RETURNS trigger AS
$body$
DECLARE
	v_activity_id VARCHAR(255);
BEGIN
	ALTER TABLE groups_activities DISABLE TRIGGER CLEAN_GROUPS_ACTIVITIES_TRG;

	IF TG_OP = 'DELETE' THEN
		SELECT t.activity_id INTO v_activity_id FROM transactions t WHERE t.transaction_id = OLD.transaction_id;
    
        IF v_activity_id IS NOT NULL THEN
        	UPDATE groups_activities
                SET COUNTER = COUNTER - 1
                WHERE
                    ACTIVITY_ID = v_activity_id
                    AND GROUP_ID = OLD.GROUP_ID;
        END IF;

		DELETE FROM groups_activities WHERE counter = 0 AND ACTIVITY_ID = v_activity_id;
    ELSE
	    SELECT t.activity_id INTO v_activity_id FROM transactions t WHERE t.transaction_id = NEW.transaction_id;
        IF v_activity_id IS NOT NULL THEN
    	    PERFORM upsert_groups_activities(NEW.GROUP_ID, v_activity_id);
        END IF;
    END IF;

    ALTER TABLE groups_activities ENABLE TRIGGER CLEAN_GROUPS_ACTIVITIES_TRG;
    
    RETURN NULL;
    
    
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

CREATE TRIGGER update_groups_activities
  AFTER INSERT OR DELETE 
  ON public.groups_transactions FOR EACH ROW 
  EXECUTE PROCEDURE public.update_groups_activities_fn();


CREATE OR REPLACE FUNCTION public.update_users_and_groups_activities_fn (
)
RETURNS trigger AS
$body$
DECLARE
	v_id VARCHAR(255);
BEGIN
	IF OLD.activity_id IS NOT NULL THEN
		UPDATE users_activities SET counter = counter - 1 WHERE activity_id = OLD.activity_id;
        UPDATE groups_activities SET counter = counter - 1 WHERE activity_id = OLD.activity_id;
    END IF;
    
    IF NEW.activity_id IS NOT NULL THEN
    	FOR v_id IN SELECT group_id FROM groups_transactions WHERE transaction_id = NEW.transaction_id
        LOOP
            PERFORM upsert_groups_activities(v_id, NEW.activity_id);
        END LOOP;
        
        FOR v_id IN SELECT user_id FROM users_transactions WHERE transaction_id = NEW.transaction_id
        LOOP
            PERFORM upsert_users_activities(v_id, NEW.activity_id);
        END LOOP;
    END IF;
    
    RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

CREATE TRIGGER update_users_and_groups_activities
  AFTER UPDATE OF activity_id 
  ON public.transactions FOR EACH ROW 
  EXECUTE PROCEDURE public.update_users_and_groups_activities_fn();


CREATE OR REPLACE FUNCTION public.invalidate_users_and_groups_solutions_from_transactions (
)
RETURNS trigger AS
$body$
BEGIN
	-- Removendo os aceites de usuário que envolvem a transação que está sendo modificada
	DELETE FROM users_solutions
	WHERE 
		conflict_id IN (SELECT conflict_id
                        FROM conflicts
                        WHERE activity1 = NEW.activity_id
                            OR activity2 = NEW.activity_id);

	-- Removendo os aceites de grupo que envolvem a transação que está sendo modificada
	DELETE FROM groups_solutions
	WHERE 
		conflict_id IN (SELECT conflict_id
                        FROM conflicts
                        WHERE activity1 = NEW.activity_id
                            OR activity2 = NEW.activity_id);
    RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

CREATE TRIGGER transactions_tr
  AFTER UPDATE OF activity_id
  ON public.transactions FOR EACH ROW 
  EXECUTE PROCEDURE public.invalidate_users_and_groups_solutions_from_transactions();


CREATE OR REPLACE FUNCTION clean_users_activities_trg_fn (
)
RETURNS trigger AS
$body$
BEGIN
  DELETE FROM USERS_ACTIVITIES WHERE counter = 0;
  RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

CREATE TRIGGER clean_users_activities_trg
  AFTER UPDATE OF counter 
  ON users_activities FOR EACH STATEMENT 
  EXECUTE PROCEDURE clean_users_activities_trg_fn();


CREATE FUNCTION invalidate_users_solutions_from_users_groups (
)
RETURNS trigger AS
$body$
BEGIN
	DELETE FROM users_solutions
	WHERE 
  		user_id = NEW.user_id
		AND conflict_id IN (SELECT conflict_id
    						FROM conflicts
    						WHERE activity1 IN (SELECT activity_id FROM groups_activities WHERE group_id = NEW.group_id)
                	        	OR activity2 IN (SELECT activity_id FROM groups_activities WHERE group_id = NEW.group_id));
    RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;

CREATE TRIGGER users_groups_tr
  AFTER INSERT 
  ON public.users_groups FOR EACH ROW 
  EXECUTE PROCEDURE public.invalidate_users_solutions_from_users_groups();


CREATE OR REPLACE FUNCTION public.update_users_activities_fn (
)
RETURNS trigger AS
$body$
DECLARE
	v_activity_id VARCHAR(255);
BEGIN
	ALTER TABLE users_activities DISABLE TRIGGER CLEAN_USERS_ACTIVITIES_TRG;

	IF TG_OP = 'DELETE' THEN
		SELECT t.activity_id INTO v_activity_id FROM transactions t WHERE t.transaction_id = OLD.transaction_id;
    
        IF v_activity_id IS NOT NULL THEN
        	UPDATE users_activities
                SET COUNTER = COUNTER - 1
                WHERE
                    ACTIVITY_ID = v_activity_id
                    AND USER_ID = OLD.USER_ID;
        END IF;

		DELETE FROM users_activities WHERE counter = 0 AND ACTIVITY_ID = v_activity_id;
    ELSE
	    SELECT t.activity_id INTO v_activity_id FROM transactions t WHERE t.transaction_id = NEW.transaction_id;
        IF v_activity_id IS NOT NULL THEN
    	    PERFORM upsert_users_activities(NEW.USER_ID, v_activity_id);
        END IF;
    END IF;

    ALTER TABLE users_activities ENABLE TRIGGER CLEAN_USERS_ACTIVITIES_TRG;
    
    RETURN NULL;
    
    
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

CREATE TRIGGER update_users_activities
  AFTER INSERT OR DELETE 
  ON public.users_transactions FOR EACH ROW 
  EXECUTE PROCEDURE public.update_users_activities_fn();


CREATE FUNCTION invalidate_users_solutions_from_users_transactions (
)
RETURNS trigger AS
$body$
DECLARE
  v_activity_id VARCHAR;
BEGIN
	SELECT activity_id FROM transactions INTO v_activity_id WHERE transaction_id = NEW.transaction_id;

	DELETE FROM users_solutions
	WHERE 
  		user_id = NEW.user_id
		AND conflict_id IN (SELECT conflict_id
    						FROM conflicts
    						WHERE activity1 = v_activity_id
                	        	OR activity2 = v_activity_id);
    RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;

CREATE TRIGGER users_transactions_tr
  AFTER INSERT 
  ON public.users_transactions FOR EACH ROW 
  EXECUTE PROCEDURE invalidate_users_solutions_from_users_transactions();

-- Table: reminders

CREATE TABLE reminders
(
  reminder_id serial NOT NULL,
  message text NOT NULL,
  created timestamp without time zone NOT NULL DEFAULT now(),
  next_alarm date NOT NULL,
  last_viewed date,
  recipient_id integer NOT NULL,
  author_id integer NOT NULL,
  dismissed boolean DEFAULT false,
  repeat integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_reminders PRIMARY KEY (reminder_id),
  CONSTRAINT fk_reminders_author_id FOREIGN KEY (recipient_id)
      REFERENCES gt_users (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_reminders_recipient_id FOREIGN KEY (recipient_id)
      REFERENCES gt_users (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE reminders
  OWNER TO sod;

-- Table: access_demands

CREATE TABLE access_demands
(
  demand_id serial NOT NULL,
  applicant_id integer NOT NULL,
  approver_id integer,
  status character varying(255) NOT NULL,
  created timestamp without time zone NOT NULL DEFAULT now(),
  user_name character varying(255) NOT NULL,
  real_name character varying(255),
  obs text,
  updated timestamp without time zone,
  reason text,
  demand_type character varying(255) NOT NULL,
  copy_user_id character varying(255),
  group1 character varying(255) DEFAULT ''::character varying,
  access_level1 character varying(4) DEFAULT ''::character varying,
  group2 character varying(255) DEFAULT ''::character varying,
  access_level2 character varying(4) DEFAULT ''::character varying,
  group3 character varying(255) DEFAULT ''::character varying,
  access_level3 character varying(4) DEFAULT ''::character varying,
  CONSTRAINT pk_access_demands PRIMARY KEY (demand_id),
  CONSTRAINT fk_applicant_id_gt_users FOREIGN KEY (applicant_id)
      REFERENCES gt_users (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_approver_id_gt_users FOREIGN KEY (approver_id)
      REFERENCES gt_users (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE access_demands
  OWNER TO sod;
