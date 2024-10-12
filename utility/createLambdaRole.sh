#!/bin/bash

# Verifica se i file di configurazione esistono
ROLE_POLICY_PATH="settings/role_policy.json"
POLICY_PATH="settings/policy.json"

if [ ! -f "$ROLE_POLICY_PATH" ]; then
  echo "Errore: Il file $ROLE_POLICY_PATH non esiste."
  exit 1
fi

if [ ! -f "$POLICY_PATH" ]; then
  echo "Errore: Il file $POLICY_PATH non esiste."
  exit 1
fi

# Creazione del ruolo IAM per Lambda
echo "Creazione del ruolo IAM lambdarole..."
aws iam create-role --role-name lambdarole --assume-role-policy-document file://"$ROLE_POLICY_PATH" --query 'Role.Arn' --endpoint-url=http://localhost:4566

# Assegnazione della policy al ruolo
echo "Assegnazione della policy lambdapolicy al ruolo IAM..."
aws iam put-role-policy --role-name lambdarole --policy-name lambdapolicy --policy-document file://"$POLICY_PATH" --endpoint-url=http://localhost:4566

echo "Ruolo IAM creato e policy assegnata correttamente."
