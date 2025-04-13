***GUÍA PARA REPRODUCIR EL ENTORNO***

Tener en cuenta que los comandos aparecen entre comillas simples (''). Estas no deben incluirse en la ejecución del comando.


1) Asegurarse de tener instalado y configurado correctamente en la máquina local lo siguiente:
	- Git.
	- Tener una cuenta de GitHub.
	- Docker Desktop, permite la visualización y contiene herramientas para ejecutar contenedores.
	- Minikube, permite ejecutar un clúster de Kubernetes de forma local.
	- kubectl, herramienta de línea de comandos para interactuar con el clúster de Kubernetes.


2) Organizar los directorios locales. En mi caso, los directorios están organizados de la siguiente manera:
	- Un directorio que contendrá todo el contenido del sitio web estático (archivos .HTML, .css, imágenes, etc).
	- Un directorio que contendrá los manifiestos de Kubernetes.


3) CLONAR EL REPOSITORIO REMOTO DEL CONTENIDO WEB A UN REPOSITORIO LOCAL

En el directorio local que contendrá el sitio web iniciar git:
	- Abrir la carpeta o directorio, puede ser con el explorador de archivos.
	- Hacer clic derecho y luego abrir la terminal.
	- Ejecutar el comando 'git init'.
	- Se puede verificar que git esté inicializado con el comando 'git status'.
	- Clonar el repositorio con el comando 'git clone https://github.com/tu-usuario/nombre-del-repositorio'.

Ahora el repositorio remoto está clonado en el repositorio local.


4) CLONAR EL REPOSITORIO REMOTO DE LOS MANIFIESTOS DE KUBERNETES AL REPOSITORIO LOCAL

En el directorio local que contendrá los manifiestos de Kubernetes:
	- Abrir la carpeta o directorio donde se guardarán los manifiestos, puede ser con el explorador de archivos.
	- Hacer clic derecho y luego abrir la terminal.
	- Ejecutar el comando 'git init'.
	- Se puede verificar que git esté inicializado con el comando 'git status'.
	- Clonar el repositorio con el comando 'git clone https://github.com/tu-usuario/nombre-del-repositorio'.

En resumen, en los pasos 4 y 5 se han clonado dos repositorios. Uno con el contenido del sitio web, y otro con los manifiestos de Kubernetes.


5) Preparar el entorno para el despliegue con Minikube. Para ello, hay que tener iniciado y configurado Docker Desktop. Luego, abrir la terminal, como PowerShell o GitBash, para poder ejecutar los comandos, o usar la misma terminal utilizada para clonar los repositorios. A continuación, realizar los siguiente:
	- Iniciar Minikube con el comando 'minikube start'.
	- Verificar el estado de Minikube con el comando 'minikube status'. Esto debería mostrar que está en estado "Running".


6) Crear un nuevo clúster (perfil) con Minikube:
	- Para crear un nuevo clúster ejecutar el comando 'minikube start -p nombre-del-cluster'.
	- Se puede verificar su creación y que se esté trabajando en el ejecutando el comando 'minikube profile list'. Esto brinda detalles, como la VM, el estado, el puerto, dirección IP, etc.


7) Una vez creado el clúster y antes de aplicar los manifiestos, es necesario montar el directorio que contiene los archivos del sitio estático en el entorno de Minikube para que los pods puedan acceder a estos. De esta forma, si se edita un archivo del contenido web, estos cambios se verán reflejados en el navegador. Para lograr esto, se debe:
	- Abrir una nueva terminal y ejecutar el comando 'minikube mount "ruta\al\directorio\del\contenido-web\static-website:/mnt/static-website"'. En mi caso el comando que ejecuté fue 'minikube mount "C:\Users\Usuario\Desktop\K8S\0311AT\web\static-website:/mnt/static-website"'
	-Dejar esta segunda terminal abierta mientras Minikube esté en funcionamiento. Si se cierra, se perderá el acceso al contenido montado.


8) Una vez montado el directorio, desde la primer terminal moverse al directorio que contiene los manifiestos con el comando 'cd path/a/directorio-manifiestos'. Y luego, se puede aplicar todos los manifiestos de una vez ejecutando el comando 'kubectl apply -f .', o bien uno por uno usando el comando 'kubectl aplly -f' para cada uno de ellos:
	- kubectl apply -f deployment.yaml
	- kubectl apply -f pv.yaml
	- kubectl apply -f pvc.yaml
	- kubectl apply -f service.yaml


9) Verificar los recursos creados ejecutando los siguientes comandos:
	- 'kubectl get all' --> debería mostrar el pod creado, el sesrvicio, el deployment y un replicaset.
	- 'kubectl get pv,pvc --> debería mostrar los volúmenes creados, ambos en estado "Bound".


10) Una vez aplicados los manifiestos, y verificado que todo esté OK, se puede exponer el servicio en el navegador de la siguiente forma:
	- Ejecutar el comando 'minikube service nombre-del-servicio' --> en este caso sería 'minikube service web-service'.
	- En la terminal se debería ver el servicio con nombre "web-service", al igual que su IP y su puerto expuesto, y la URL pública que se puede usar para acceder al servicio desde la máquina.
	- El navegador debería abrirse automáticamente luego de haber ejecutado el comando, y mostrar la página web estática.


De esta forma se asegura de que el despliegue de los recursos sea el correcto, utilizando manifiestos previamente configurados y garantizando que el sitio web se encuentre accesible desde el servicio expuesto.
Este procedimiento permite validar que, tanto los volúmenes como el contenido web estén correctamente montados y, que los cambios realizados en los archivos locales se reflejen de manera inmediata en el navegador al recargar el mismo. Lo cual es útil para entornos de desarrollo y pruebas.
