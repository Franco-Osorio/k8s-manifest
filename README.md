***GUÍA PARA REPRODUCIR EL ENTORNO***

Tener en cuenta que los comandos aparecen entre comillas simples (''). Estas no deben incluirse en la ejecución del comando.


1) ASEGURAR LO SIGUIENTE:

Tener instalado y configurado correctamente en la máquina local lo siguiente:
	- Git.
	- Tener una cuenta de GitHub.
	- Docker Desktop, permite la visualización y contiene herramientas para ejecutar contenedores.
	- Minikube, permite ejecutar un clúster de Kubernetes de forma local.
	- kubectl, herramienta de línea de comandos para interactuar con el clúster de Kubernetes.


2) CREAR UN DIRECTORIO PARA LOS REPOSITORIOS LOCALES:

	- Crear un directorio local para clonar dentro de este el repositorio del sitio web estático y el repositorio de los manifiestos de Kubernetes.


3) CLONAR LOS REPOSITORIOS REMOTOS DEL CONTENIDO WEB Y DE LOS MANIFIESTOS A UN REPOSITORIO LOCAL:

En el directorio local creado anteriormente:
	- Abrir la carpeta o directorio, puede ser con el explorador de archivos.
	- Hacer clic derecho y luego abrir la terminal.
	- Ejecutar el comando 'git init'.
	- Se puede verificar que git esté inicializado con el comando 'git status'. Este comando debe mostrar un mensaje que se está parado sobre la rama master (On branch master) y que no hay commits pendientes.
	- Clonar el repositorio remoto del sitio web con el comando 'git clone https://github.com/tu-usuario/nombre-del-repositorio-del-sitio-web-estatico'.
	- Revisar en el directorio local que se haya clonado correctamente, verificando carpetas y archivos.
	- Repetir el proceso con para el repositorio de los manifiestos. Ejecutar el comando 'git clone https://github.com/tu-usuario/nombre-del-repositorio-de-los-manifiestos'.
	- Revisar en el directorio local que también se haya clonado correctamente, verificando carpetas y archivos.

Ahora ambos repositorios han sido clonados en un repositorio local para cada uno de ellos.


4) PREPARAR EL ENTORNO PARA EL DESPLIEGUE CON MINIKUBE:

Para ello, hay que tener iniciado y configurado Docker Desktop. Luego, abrir la terminal, como PowerShell o GitBash, para poder ejecutar los comandos, o usar la misma terminal utilizada para clonar los repositorios. A continuación, realizar los siguiente:
	- Iniciar Minikube con el comando 'minikube start'.
	- Verificar el estado de Minikube con el comando 'minikube status'. Esto debería mostrar que está en estado "Running".


5) CREAR UN NUEVO CLUSTER (PERFIL) CON MINIKUBE:

	- Para crear un nuevo clúster ejecutar el comando 'minikube start -p nombre-del-cluster'.
	- Asegurarse que este sea el entorno con el comando 'minikube profile nombre-del-cluster'.
	- Se puede verificar su creación y que se esté trabajando en el ejecutando el comando 'minikube profile list'. Esto brinda detalles, como la VM, el estado, el puerto, dirección IP, etc. Asegurarse de que se marca con un '*' las columnas "Active Profile" y "Active Kubecontext".
	- También se puede verificar que se está usando el cluster correcto con el comando 'kubectl config current-context'.


6) MONTAR EL DIRECTORIO DEL SITIO WEB ESTATICO EN EL ENTORNO DE MINIKUBE:

Una vez creado el clúster y antes de aplicar los manifiestos, es necesario montar el directorio que contiene los archivos del sitio estático en el entorno de Minikube para que los pods puedan acceder a estos. De esta forma, si se edita un archivo del contenido web, estos cambios se verán reflejados en el navegador. Para lograr esto, se debe:

	- Copiar la ruta del directorio del sitio web estático.
	- Abrir una nueva terminal y ejecutar el comando 'minikube mount "ruta\al\directorio\del\contenido-web\static-website:/mnt/static-website"', remplazando la ruta de ejemplo por la del directorio copiado anteriormente, pero agregando ':/mnt/static-website' a la ruta luego de pegarla. En mi caso el comando que ejecuté fue 'minikube mount "C:\Users\Usuario\Desktop\K8S\0311AT\web\static-website:/mnt/static-website"'.
	-Dejar esta segunda terminal abierta mientras Minikube esté en funcionamiento. Si se cierra, se perderá el acceso al contenido montado.


7) APLICAR LOS MANIFIESTOS:

Una vez montado el directorio, desde la primer terminal moverse al directorio que contiene los manifiestos con el comando 'cd path/a/directorio-manifiestos/k8s-manifest'. Y luego, se puede aplicar todos los manifiestos de una vez ejecutando el comando 'kubectl apply -f .', o bien uno por uno usando el comando 'kubectl aplly -f' para cada uno de ellos:
	- kubectl apply -f pv.yaml
	- kubectl apply -f pvc.yaml
	- kubectl apply -f deployment.yaml
	- kubectl apply -f service.yaml


8) VERIFICAR LOS RECURSOS CREADOS:

Para ello ejecutar los siguientes comandos:
	- 'kubectl get all' --> debería mostrar el pod creado, el sesrvicio, el deployment y un replicaset.
	- 'kubectl get pv,pvc --> debería mostrar los volúmenes creados, ambos en estado "Bound".


10) EXPONER EL SERVICIO EN EL NAVEGADOR WEB:

Una vez aplicados los manifiestos, y verificado que todo esté OK, se puede exponer el servicio en el navegador de la siguiente forma:
	- Ejecutar el comando 'minikube service nombre-del-servicio' --> en este caso es 'minikube service web-service'.
	- En la terminal se debería ver el servicio con nombre "web-service", al igual que su IP y su puerto expuesto, y la URL pública que se puede usar para acceder al servicio desde la pc.
	- El navegador debería abrirse automáticamente luego de haber ejecutado el comando, y mostrar la página web estática.


De esta forma se asegura de que el despliegue de los recursos sea el correcto, utilizando manifiestos previamente configurados y garantizando que el sitio web se encuentre accesible desde el servicio expuesto.
Este procedimiento permite validar que, tanto los volúmenes como el contenido web estén correctamente montados y, que los cambios realizados en los archivos locales se reflejen de manera inmediata en el navegador al recargar el mismo. Lo cual es útil para entornos de desarrollo y pruebas.
