import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cii/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Caminho Feliz - Fluxo de Navegação Principal', () {
    testWidgets(
      'Deve navegar por todas as abas principais e verificar visibilidade',
      (WidgetTester tester) async {
        print('🚀 Iniciando teste de integração...');

        // 1. Iniciar o App
        // O main() do projeto configura Riverpod, Modular e Servicos
        app.main();

        print('⏳ Aguardando app inicializar...');
        // Aguarda o primeiro frame
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        print('🧐 Verificando tela inicial...');

        // Tenta encontrar por texto ou ícone para ser resiliente
        final homeLabel = find.text('Casa');
        final homeIcon = find.byIcon(Icons.home);

        if (homeLabel.evaluate().isEmpty) {
          print(
            '⚠️ Texto "Casa" não encontrado. Tentando encontrar qualquer texto para diagnóstico...',
          );
          final allText = find.byType(Text).evaluate();
          for (var element in allText) {
            final widget = element.widget as Text;
            print('   Found text: "${widget.data}"');
          }
        }

        expect(
          homeIcon,
          findsOneWidget,
          reason: 'O ícone de Casa deve estar visível no BottomBar',
        );

        // 3. Navegar para aba 'Água'
        final abaAgua = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(Icons.water_drop),
        );
        await tester.tap(abaAgua);
        await tester.pumpAndSettle();

        // Validar se o conteúdo da aba Água apareceu (ou mensagem de vazio)
        expect(find.text('Água'), findsWidgets);
        // Pode aparecer 'Nenhum recurso de água...' se o DB estiver vazio no teste
        bool temRecursosAgua = find.byType(ListView).evaluate().isNotEmpty;
        if (!temRecursosAgua) {
          expect(find.textContaining('Nenhum recurso'), findsOneWidget);
        }

        // 4. Navegar para aba 'Ambiente'
        final abaAmbiente = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(Icons.thermostat),
        );
        await tester.tap(abaAmbiente);
        await tester.pumpAndSettle();

        expect(find.text('Ambiente'), findsWidgets);
        bool temSensores = find.byType(ListView).evaluate().isNotEmpty;
        if (!temSensores) {
          expect(find.textContaining('Nenhum sensor'), findsOneWidget);
        }

        // 5. Navegar para aba 'Eventos'
        final abaEventos = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(Icons.notifications_active),
        );
        await tester.tap(abaEventos);
        await tester.pumpAndSettle();

        expect(find.text('Eventos'), findsWidgets);
        // Na aba eventos temos o TabBar interno (Alertas, Eventos, Presenca)
        expect(find.text('Alertas'), findsOneWidget);
        expect(find.text('Presença'), findsOneWidget);

        // 6. Retornar para 'Casa'
        final abaCasaBtn = find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(Icons.home),
        );
        await tester.tap(abaCasaBtn);
        await tester.pumpAndSettle();

        expect(find.byType(CustomScrollView), findsOneWidget);

        print('✅ Teste de Integração: Caminho Feliz concluído com sucesso!');
      },
    );
  });
}
