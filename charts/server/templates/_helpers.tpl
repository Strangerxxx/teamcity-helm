{{/*
Expand the name of the chart.
*/}}
{{- define "server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "server.labels" -}}
helm.sh/chart: {{ include "server.chart" . }}
{{ include "server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper Storage Class
{{ include "server.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "server.storage.class" -}}
{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "server.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "server.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Renders a config for configmaps
*/}}
{{- define "server.config" -}}
{{- include "server.tplvalues.render" ( dict "value" ((.Files.Glob "config/*").AsConfig) "context" $) }}
{{- end -}}

{{/*
Create a default fully qualified app name for postgresql.
*/}}
{{- define "server.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "server-postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "server.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "server.postgresql.fullname" . -}}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.host is required" .Values.externalPostgresql.host }}
{{- end -}}
{{- end -}}

{{/*
Set postgres port
*/}}
{{- define "server.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{- default 5432 .Values.postgresql.primary.service.ports.postgresql -}}
{{- else -}}
{{- required "A valid .Values.externalPostgresql.port is required" .Values.externalPostgresql.port -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql database
*/}}
{{- define "server.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "teamcity" .Values.postgresql.postgresqlDatabase }}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.database is required" .Values.externalPostgresql.database }}
{{- end -}}
{{- end -}}


{{/*
Set postgresql username
*/}}
{{- define "server.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "postgres" .Values.postgresql.postgresqlUsername }}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.username is required" .Values.externalPostgresql.username }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql password
*/}}
{{- define "server.postgresql.password" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "" .Values.postgresql.postgresqlPassword }}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.password is required" .Values.externalPostgresql.password }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql connection URL
*/}}
{{- define "server.postgresql.url" -}}
{{- $postgresHost := include "server.postgresql.host" . -}}
{{- $postgresPort := include "server.postgresql.port" . -}}
{{- $postgresDatabase := include "server.postgresql.database" . -}}
{{- printf "jdbc:postgresql://%s:%s/%s" $postgresHost $postgresPort $postgresDatabase }}
{{- end -}}

{{/*
Set jdbc maven artifact name
*/}}
{{- define "server.jdbc.artifact" -}}
{{- with .Values.downloadJDBC.maven -}}
{{ printf "%s:%s:%s:%s" .groupId .artifactId .version .packaging }}
{{- end -}}
{{- end -}}

{{/*
Set jdbc maven artifact url
*/}}
{{- define "server.jdbc.artifactUrl" -}}
{{- with .Values.downloadJDBC.maven -}}
{{ printf "https://repo1.maven.org/maven2/%s/%s/%s/%s-%s.%s" (.groupId | replace "." "/") .artifactId .version .artifactId .version .packaging }}
{{- end -}}
{{- end -}}
