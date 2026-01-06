#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

/**
 * DesktopVideoApp: Papel de parede animado com suporte a persistência,
 * múltiplos monitores e login automático.
 */

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(strong) NSMutableArray<NSWindow *> *windows;
@property(strong) AVQueuePlayer *player;
@property(strong) AVPlayerLooper *playerLooper;
@property(strong) NSMutableArray<AVPlayerLayer *> *playerLayers;
@property(strong) NSStatusItem *statusItem;
@property(assign)
    BOOL isVisible; // Rastreia visibilidade para pausa inteligente
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
  self.windows = [NSMutableArray array];
  self.playerLayers = [NSMutableArray array];

  [self setupMenuBar];

  // Sincroniza o estado do Login Item com a preferência salva
  [self syncLoginItemWithPreference];

  // Tenta carregar o último vídeo salvo
  NSString *lastPath =
      [[NSUserDefaults standardUserDefaults] stringForKey:@"LastVideoPath"];
  if (lastPath && [[NSFileManager defaultManager] fileExistsAtPath:lastPath]) {
    [self setupWindowsAndPlayer:[NSURL fileURLWithPath:lastPath]];
  } else {
    [self changeVideo:nil];
  }
}

- (void)setupMenuBar {
  self.statusItem = [[NSStatusBar systemStatusBar]
      statusItemWithLength:NSVariableStatusItemLength];

  // Ícone de sistema (emoji)
  self.statusItem.button.title = @"🎬";

  NSMenu *menu = [[NSMenu alloc] init];
  [menu addItemWithTitle:@"Trocar Vídeo"
                  action:@selector(changeVideo:)
           keyEquivalent:@"n"];

  // Item para Mutar
  NSMenuItem *muteItem =
      [[NSMenuItem alloc] initWithTitle:@"Mudo"
                                 action:@selector(toggleMute:)
                          keyEquivalent:@"m"];
  muteItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsMuted"]
                       ? NSControlStateValueOn
                       : NSControlStateValueOff;
  [menu addItem:muteItem];

  // Item para Iniciar no Login (usa preferência salva como fonte da verdade)
  NSMenuItem *loginItem =
      [[NSMenuItem alloc] initWithTitle:@"Iniciar no Login"
                                 action:@selector(toggleLoginItem:)
                          keyEquivalent:@""];
  BOOL shouldStartAtLogin =
      [[NSUserDefaults standardUserDefaults] boolForKey:@"StartAtLogin"];
  loginItem.state =
      shouldStartAtLogin ? NSControlStateValueOn : NSControlStateValueOff;
  [menu addItem:loginItem];

  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:@"Sair"
                  action:@selector(terminateApp:)
           keyEquivalent:@"q"];
  self.statusItem.menu = menu;
}

- (void)changeVideo:(id)sender {
  [NSApp activateIgnoringOtherApps:YES];
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setTitle:@"Selecione um vídeo"];
  [panel setAllowedFileTypes:@[ @"mp4", @"mov", @"m4v" ]];

  if ([panel runModal] == NSModalResponseOK) {
    NSURL *videoURL = [[panel URLs] firstObject];
    // Persiste a escolha
    [[NSUserDefaults standardUserDefaults] setObject:videoURL.path
                                              forKey:@"LastVideoPath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupWindowsAndPlayer:videoURL];
  } else if (self.windows.count == 0) {
    [NSApp terminate:self];
  }
}

- (void)toggleMute:(NSMenuItem *)sender {
  BOOL mute = (sender.state == NSControlStateValueOff);
  sender.state = mute ? NSControlStateValueOn : NSControlStateValueOff;
  self.player.muted = mute;
  [[NSUserDefaults standardUserDefaults] setBool:mute forKey:@"IsMuted"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupWindowsAndPlayer:(NSURL *)videoURL {
  // Desativa animações implícitas para as mudanças a seguir
  [CATransaction begin];
  [CATransaction setDisableActions:YES];

  // Configura o item de vídeo com buffer reduzido (Requisito 3)
  AVAsset *asset = [AVAsset assetWithURL:videoURL];
  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
  playerItem.preferredForwardBufferDuration = 1.0; // Buffer de 1 segundo
  playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;

  // Cria o player apenas se não existir (Requisito 1)
  if (!self.player) {
    self.player = [AVQueuePlayer queuePlayerWithItems:@[ playerItem ]];
    self.player.automaticallyWaitsToMinimizeStalling =
        NO; // Otimização de latência
  } else {
    [self.player removeAllItems];
    [self.player insertItem:playerItem afterItem:nil];
  }

  // Reinicia o looper para o novo item
  self.playerLooper = [AVPlayerLooper playerLooperWithPlayer:self.player
                                                templateItem:playerItem];

  // Reaproveita janelas se possível; se a contagem de monitores mudou, limpa
  // tudo.
  if (self.windows.count != [NSScreen screens].count) {
    for (NSWindow *win in self.windows)
      [win close];
    [self.windows removeAllObjects];
    [self.playerLayers removeAllObjects];

    for (NSScreen *screen in [NSScreen screens]) {
      NSWindow *window =
          [[NSWindow alloc] initWithContentRect:screen.frame
                                      styleMask:NSWindowStyleMaskBorderless
                                        backing:NSBackingStoreBuffered
                                          defer:NO];
      [window setBackgroundColor:[NSColor blackColor]];
      [window setLevel:kCGDesktopWindowLevel]; // Wallpaper level
      [window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces |
                                    NSWindowCollectionBehaviorStationary];
      [window setIgnoresMouseEvents:YES];

      // Otimização: Desativa animações da janela
      [window setAnimationBehavior:NSWindowAnimationBehaviorNone];

      [[window contentView] setWantsLayer:YES];
      AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];

      // Desativa animações implícitas na camada (Requisito 4)
      layer.actions = @{
        @"position" : [NSNull null],
        @"bounds" : [NSNull null],
        @"contents" : [NSNull null],
        @"sublayers" : [NSNull null]
      };

      [layer setFrame:[[window contentView] bounds]];
      [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
      [[[window contentView] layer] addSublayer:layer];

      [window makeKeyAndOrderFront:nil];
      [self.windows addObject:window];
      [self.playerLayers addObject:layer];

      // Observa visibilidade da janela (Requisito: Pausa apenas em tela cheia)
      [[NSNotificationCenter defaultCenter]
          addObserver:self
             selector:@selector(checkVisibility)
                 name:NSWindowDidChangeOcclusionStateNotification
               object:window];
    }

    // Observa troca de Spaces para garantir que não pausamos indevidamente (Log
    // e controle)
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self
           selector:@selector(handleSpaceChange)
               name:NSWorkspaceActiveSpaceDidChangeNotification
             object:nil];

    // Observa ativação de apps para debug (Requisito 3)
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self
           selector:@selector(handleAppActivation:)
               name:NSWorkspaceDidActivateApplicationNotification
             object:nil];
  } else {
    // Apenas atualiza o player no layer existente
    for (AVPlayerLayer *layer in self.playerLayers) {
      layer.player = self.player;
    }
  }

  // Aplica estado de mudo persistido
  self.player.muted =
      [[NSUserDefaults standardUserDefaults] boolForKey:@"IsMuted"];

  self.isVisible = YES;
  [self.player play];
  NSLog(@"[DesktopVideo DevLog] Reprodução iniciada/atualizada: %@",
        videoURL.lastPathComponent);

  [CATransaction commit];
}

// Log quando troca de Space (Requisito 1: Não pausar aqui)
- (void)handleSpaceChange {
  NSLog(@"[DesktopVideo DevLog] Espaço alterado (Space Change). Mantendo "
        @"reprodução.");
  // Garante que continue dando play se estivermos trocando de espaço
  if (!self.isVisible) {
    [self.player play];
    self.isVisible = YES;
  }
}

// Log quando um app é ativado (ajuda a identificar transições de tela cheia)
- (void)handleAppActivation:(NSNotification *)notification {
  NSRunningApplication *app = notification.userInfo[NSWorkspaceApplicationKey];
  NSLog(@"[DesktopVideo DevLog] App ativado: %@", app.localizedName);
}

// Otimização: Pausa o vídeo apenas quando o desktop está totalmente oculto
// (Requisito 2 e 5)
- (void)checkVisibility {
  BOOL anyVisible = NO;
  for (NSWindow *win in self.windows) {
    if (win.occlusionState & NSWindowOcclusionStateVisible) {
      anyVisible = YES;
      break;
    }
  }

  if (anyVisible && !self.isVisible) {
    [self.player play];
    self.isVisible = YES;
    NSLog(@"[DesktopVideo DevLog] Vídeo retomado: Desktop visível.");
  } else if (!anyVisible && self.isVisible) {
    // Verifica se não é apenas uma transição rápida
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          BOOL stillHidden = YES;
          for (NSWindow *win in self.windows) {
            if (win.occlusionState & NSWindowOcclusionStateVisible) {
              stillHidden = NO;
              break;
            }
          }
          if (stillHidden && self.isVisible) {
            [self.player pause];
            self.isVisible = NO;
            NSLog(@"[DesktopVideo DevLog] Vídeo pausado: Desktop oculto "
                  @"(possível App em Tela Cheia).");
          }
        });
  }
}

- (void)syncLoginItemWithPreference {
  if (@available(macOS 13.0, *)) {
    BOOL shouldBeEnabled =
        [[NSUserDefaults standardUserDefaults] boolForKey:@"StartAtLogin"];
    SMAppService *service = [SMAppService mainAppService];

    BOOL isCurrentlyEnabled = (service.status == SMAppServiceStatusEnabled);
    if (shouldBeEnabled != isCurrentlyEnabled) {
      NSError *error = nil;
      if (shouldBeEnabled) {
        if (![service registerAndReturnError:&error]) {
          NSLog(@"[LoginItem] Falha ao registrar na sincronização: %@",
                error.localizedDescription);
        }
      } else {
        if (![service unregisterAndReturnError:&error]) {
          NSLog(@"[LoginItem] Falha ao desregistrar na sincronização: %@",
                error.localizedDescription);
        }
      }
    }
  }
}

- (void)toggleLoginItem:(NSMenuItem *)sender {
  BOOL enable = (sender.state == NSControlStateValueOff);

  // Salva a intenção do usuário imediatamente
  [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"StartAtLogin"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  // Atualiza a UI imediatamente para parecer responsivo
  sender.state = enable ? NSControlStateValueOn : NSControlStateValueOff;

  // Tenta sincronizar com o sistema
  if (@available(macOS 13.0, *)) {
    SMAppService *service = [SMAppService mainAppService];
    NSError *error = nil;
    if (enable) {
      if (![service registerAndReturnError:&error]) {
        NSLog(@"[LoginItem] Erro ao registrar: %@", error.localizedDescription);
      } else {
        NSLog(@"[LoginItem] Registrado com sucesso.");
      }
    } else {
      if (![service unregisterAndReturnError:&error]) {
        NSLog(@"[LoginItem] Erro ao desregistrar: %@",
              error.localizedDescription);
      } else {
        NSLog(@"[LoginItem] Desregistrado com sucesso.");
      }
    }
  }
}

- (void)terminateApp:(id)sender {
  [NSApp terminate:self];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)sender {
  return YES;
}
@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = [NSApplication sharedApplication];
    AppDelegate *delegate = [[AppDelegate alloc] init];
    [app setDelegate:delegate];
    [app run];
  }
  return 0;
}
