#!/usr/bin/env pwsh

# Script completo para setup inicial do Video Processor

Write-Host "🎬 Setup Completo do Video Processor" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# 1. Rebuild da imagem Docker
Write-Host "🐳 Reconstruindo imagem Docker..." -ForegroundColor Cyan
Set-Location "..\hacka-app-processor"

# Build da aplicação
Write-Host "🔨 Compilando aplicação..." -ForegroundColor Yellow
& npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na compilação" -ForegroundColor Red
    exit 1
}

# Build da imagem Docker
Write-Host "🐳 Criando imagem Docker..." -ForegroundColor Yellow
& docker build -t video-processor .
& docker tag video-processor:latest maickway/video-processor:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na criação da imagem Docker" -ForegroundColor Red
    exit 1
}

# 2. Push para Docker Hub (opcional)
$pushToHub = Read-Host "Deseja fazer push para o Docker Hub? (y/N)"
if ($pushToHub -eq "y" -or $pushToHub -eq "Y") {
    Write-Host "📤 Fazendo push para Docker Hub..." -ForegroundColor Yellow
    & docker push maickway/video-processor:latest
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erro no push para Docker Hub" -ForegroundColor Red
        exit 1
    }
}

# 3. Deploy da infraestrutura
Write-Host "🏗️ Iniciando deploy da infraestrutura..." -ForegroundColor Cyan
Set-Location "..\terraform-orchestration-video"

# Executar o script de deploy
& .\deploy-video-processor.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro no deploy da infraestrutura" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 Setup completo concluído com sucesso!" -ForegroundColor Green
Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Acesse o AWS Console para verificar os recursos" -ForegroundColor White
Write-Host "   2. Monitore os logs no CloudWatch: /ecs/video-processor" -ForegroundColor White
Write-Host "   3. Teste o upload de vídeos para a fila SQS" -ForegroundColor White
Write-Host "   4. Verifique os arquivos processados no bucket S3" -ForegroundColor White

# Voltar ao diretório original
Set-Location ..
