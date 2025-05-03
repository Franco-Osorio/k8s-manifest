
#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
# Scirp de despliegue automático de sitio web estático en Kubernetes
# Autor: Franco Osorio Scheggia
# Fecha: Abril 2025
# Descripción:
#    Este script despliega un sitio web estático en un cluster Kubernetes local usando Minikube.
#
#----------------------------------------------------------------------------------------------------------------
# ESTE SCRIPT REQUIERE LO SIGUIENTE:
#   -TENER CONFIGURADA LA CONEXIÓN SSH CON GITHUB.
#   -TENER INSTALADO MINIKUBE
#   -TENER INSTALADO DOCKER
#
#----------------------------------------------------------------------------------------------------------------


# Se verifica que Minikube esté instalado.
if ! command -v minikube &> /dev/null; then
	echo "Minikube no está instalado. Abortando..."
	exit 1
fi

# Se verifica que Docker esté instalado.
if ! command -v docker &> /dev/null; then
	echo "Docker no está instalado. Abortando..."
	exit 1
fi

#Se verifica que el usuario pertenezca al grupo Docker.
if ! groups | grep -q '\bdocker\b'; then
	echo "El usuario local no pertencece al grupo docker. Debe ejecutar el comando:"
	echo "sudo usermod -aG docker \$USER && newgrp docker"
	exit 1
fi

# Se define variable del directorio, de los repositorios de GitHub y los directorios de los repositorios locales
DIRECTORIO="despliegue-k8s"
URL_REPO_WEBSITE="git@github.com:Franco-Osorio/static-website.git"
NAME_REPO_WEBSITE="static-website"
DIR_WEBSITE="$PWD/$NAME_REPO_WEBSITE"
URL_REPO_MANIFEST="git@github.com:Franco-Osorio/k8s-manifest.git"
NAME_REPO_MANIFEST="k8s-manifest"
DIR_MANIFEST="$PWD/$NAME_REPO_MANIFEST"

#Se crea el directorio donde se alojaran los repositorios
mkdir -p "$DIRECTORIO"
RUTA_DIR="$(xdg-user-dir DESKTOP)/despliegue-k8s"

#Se mueve al directorio
cd "$RUTA_DIR" || exit 1

#Se clona el repositorio del sitio web estatico
#También valida que la clonación del repositorio no falle por falta de conexión ssh
if [ -d "$DIR_WEBSITE" ] && [ -d "$DIR_WEBSITE/.git" ]; then
	echo "Repositorio existente. Actualizando..."
	cd "$DIR_WEBSITE"

	if ! git pull; then
		echo "Error: Falló actualización. Verificar conexión SSH con GitHub."
		exit 1
	fi
	echo "Actualización exitosa."

	cd ..
elif [ -d "$DIR_WEBSITE" ]; then
	echo "Error: El directorio '$DIR_WEBSITE' ya existe pero no es un repositorio Git."
	echo "Por favor, elimínelo manualmente o conviértalo en un repositorio válido."
	exit 1
else
	echo "Repositorio no encontrado. Clonando..."
	if ! git clone "$URL_REPO_WEBSITE"; then
		echo "Error: Falló la clonación del repositorio. Verificar conexión SSH con GitHub."
		exit 1
	fi
	echo "Repositorio clonado exitosamente."
fi

#Se clona el repositorio de los manifiestos
#También valida que la clonación del repositorio no falle por falta de conexión ssh
if [ -d "$DIR_MANIFEST" ] && [ -d "$DIR_MANIFEST/.git" ]; then
	echo "Repositorio existente. Actualizando..."
	cd "$DIR_MANIFEST" || {
		echo "Error: No se pudo acceder al directorio del repositorio."
		exit 1
	}

	if ! git pull; then
		echo "Error: Falló actualización. Verificar conexión SSH con GitHub."
		exit 1
	fi
	echo "Acutalización exitosa."
	cd ..
elif [ -d "$DIR_MANIFEST" ]; then
	echo "Error: El directorio '$DIR_MANIFEST' ya existe pero no es un repositorio Git."
	echo "Por favor, elimínelo manualmente o conviértalo en un repositorio válido."
	exit 1
else
	echo "Repositorio no encontrado. Clonando..."
	if ! git clone "$URL_REPO_MANIFEST"; then
		echo "Error: Falló la clonación del repositorio. Verificar conexión SSH con GitHub."
		exit 1
	fi
	echo "Repositorio clonado correctamente."
fi

echo "Directorio $DIRECTORIO creado y repositorios clonados:"
ls -d */

#Se inicia Minikube y se verifica su estado
echo "Iniciando Minikube..."
minikube start
echo "Estado de Minikube:"
minikube status

#Variable con el directorio del sitio web estatico
export STATIC_WEBSITE_DIR="$(xdg-user-dir DESKTOP)/despliegue-k8s/static-website"
#Variable con el directorio de los manifiestos
MANIFEST_DIR="$(xdg-user-dir DESKTOP)/despliegue-k8s/k8s-manifest"

#Se crea un script temporal para el montaje del sitio web
MOUNT_SCRIPT=$(mktemp /tmp/mount_website.XXXXXX.sh)

cat << 'EOF' > "$MOUNT_SCRIPT"
#!/bin/bash
echo ""
echo "Iniciando montaje del sitio web estático en Minikube..."

# Se asegura que el directorio exista en Minikube
minikube ssh -- sudo mkdir -p /mnt/static-website
minikube ssh -- sudo chown -R $(whoami):$(whoami) /mnt/static-website

#Se asegura que se elimine el script temporal al cerrar la segunda terminal
trap "echo 'Eliminando el script temporal...'; rm -- '$0" EXIT

newgrp docker <<EONG

#Se monta el directorio del sitio web estatico
minikube mount "$STATIC_WEBSITE_DIR":/mnt/static-website
EONG

echo "Montaje finalizado."
echo ""
EOF

#Se otorgan permisos de ejecución
chmod +x "$MOUNT_SCRIPT"

#Lo ejecuta en una nueva terminal
gnome-terminal -- bash -c "$MOUNT_SCRIPT; exec bash" &
echo "Continuando con el despliegue..."

#Espera 5 segundos para asegurar que el montaje este activo y listo
sleep 5

cd "$MANIFEST_DIR"

#Se aplican los manifiestos. Espera 2 segundos entre los apply de los manifiestos
echo "Aplicando manifiestos..."

kubectl apply -f pv.yaml
sleep 2

kubectl apply -f pvc.yaml
sleep 2

kubectl apply -f deployment.yaml
sleep 2

kubectl apply -f service.yaml
sleep 2

echo "Manifiestos aplicados."

#Se verifican el estado de los pods.
echo "Esperando a que los pods estén en estado Running..."

while [[ $(kubectl get pods --no-headers | grep -v 'Running\|Completed') ]]; do
  sleep 2
done
echo "***Todos los pods están en Running.***"

#Se muestra el estado de los pods
kubectl get pods

#Esta función elimina el despliegue
cleanup() {
    echo -e "\n\nInterrupción detectada. Cerrando Minikube y limpiando..."
    kubectl delete all --all
    kubectl delete -f "$MANIFEST_DIR"
    minikube stop
    echo "Minikube detenido y despliegue eliminado."
    echo "Limpieza finalizada. ¡Hasta la próxima!"
    exit 0
}

# Captura Ctrl+C
trap cleanup SIGINT

#Se expone el servicio en el navegador.
echo "Abriendo el servicio web en el navegador..."
echo ""
echo "***PRESIONE CTRL+C PARA FINALIZAR EL SERVICIO Y EL DESPLIEGUE.***"
echo ""
minikube service web-service

#Se expone el servicio en el navegador.
echo "Abriendo el servicio web en el navegador..."
echo ""
minikube service web-service &
echo ""
echo "***PRESIONE CTRL+C PARA FINALIZAR EL SERVICIO Y EL DESPLIEGUE.***"
echo ""

#Espera indefinicamente para capturar Ctrl+C y finalizar la ejecucion del script
while true; do sleep 1; done
