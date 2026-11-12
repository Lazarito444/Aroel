import 'package:aroel/core/account_controller.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:aroel/ui/widgets/paper_notice.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:aroel/ui/widgets/paper_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Deleting the account, in two confirmed steps (§5.9, US-106).
///
/// The screen states plainly what happens on the device and what happens on the server:
/// the local data goes at once, the copy on the server goes within twenty-four hours,
/// and nothing is kept.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final TextEditingController _confirmation = TextEditingController();
  bool _firstStep = true;

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(accountControllerProvider);
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      title: 'Delete account',
      child: ListView(
        children: <Widget>[
          if (_firstStep) ...<Widget>[
            Text('Everything goes', style: type.display),
            const SizedBox(height: Space.xs),
            Text(
              'The journal on this device is wiped now. The copy on the server is wiped '
              'within 24 hours. Nothing is kept, and the account is not left switched '
              'off — there is nothing to come back to.',
              style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
            ),
            const SizedBox(height: Space.lg),
            PaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Line(
                    label: 'On this device',
                    value: 'Everything is wiped now.',
                  ),
                  const SizedBox(height: Space.sm),
                  _Line(
                    label: 'On the server',
                    value: 'The copy is wiped within 24 hours.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            PaperButton(
              label: 'Continue',
              onPressed: () => setState(() => _firstStep = false),
            ),
            const SizedBox(height: Space.xs),
            PaperButton(
              label: 'Not now',
              variant: PaperButtonVariant.quiet,
              onPressed: () => context.go('/settings/account'),
            ),
          ] else ...<Widget>[
            Text('One last thing', style: type.display),
            const SizedBox(height: Space.xs),
            Text(
              'Type delete to confirm. There is no way back from this.',
              style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
            ),
            const SizedBox(height: Space.lg),
            PaperTextField(
              label: 'Type delete',
              controller: _confirmation,
              hint: 'delete',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.lg),
            PaperButton(
              label: 'Delete everything',
              variant: PaperButtonVariant.destructive,
              busy: auth.busy,
              onPressed: _confirmation.text.trim().toLowerCase() == 'delete'
                  ? () async {
                      final bool deleted = await ref
                          .read(accountControllerProvider.notifier)
                          .deleteAccount();
                      if (deleted && context.mounted) {
                        context.go('/');
                      }
                    }
                  : null,
            ),
            const SizedBox(height: Space.xs),
            PaperButton(
              label: 'Not now',
              variant: PaperButtonVariant.quiet,
              onPressed: () => context.go('/settings/account'),
            ),
          ],
          if (auth.errorMessage != null) ...<Widget>[
            const SizedBox(height: Space.md),
            PaperNotice(auth.errorMessage!, tone: NoticeTone.error),
          ],
        ],
      ),
    );
  }
}

/// A line that says what happens where.
class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 96,
          child: Text(
            label.toUpperCase(),
            style: type.label.copyWith(color: tokens.palette.inkSoft),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: type.uiBody.copyWith(color: tokens.palette.ink),
          ),
        ),
      ],
    );
  }
}
