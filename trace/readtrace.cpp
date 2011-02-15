#include <iostream>
#include <cstdio>

#include "pin_trace.h"

using namespace std;

int main(int argc, char **argv) {

   pintrace::TraceReader tr(argv[1]);

   printf("Frame count: %d\n", tr.count());

   while(tr.pos() < tr.count()) {
      printf("No: %u\n", tr.pos());

      pintrace::Frame *f = tr.next();

      switch(f->type) {
      case FRM_STD:
         {
            pintrace::StdFrame *sf = (pintrace::StdFrame *) f;
            printf("Standard frame.\n");
            printf("Addr: 0x%x\n", sf->addr);
            printf("TID: %d\n", sf->tid);
            printf("Insn length: %d\n", sf->insn_length);
            printf("Values count: %d\n", sf->values_count);

            printf("Insn bytes: ");

            unsigned int len =
               (sf->insn_length == 0) ? MAX_INSN_BYTES : sf->insn_length;

            for (unsigned int i = 0; i < len; i++) {
               printf("%02hhx ", sf->rawbytes[i]);
            }

            printf("\n");

            printf("=================================\n");

            delete f;
            break;
         }
      case FRM_KEY:
         {
            pintrace::KeyFrame *kf = (pintrace::KeyFrame *) f;
            printf("Keyframe.\n");
            printf("eax = 0x%x\n", kf->eax);
            printf("ebx = 0x%x\n", kf->ebx);
            printf("ecx = 0x%x\n", kf->ecx);
            printf("edx = 0x%x\n", kf->edx);
            break;
         }
      default:
         break;
      }

   }
   return 0;
}