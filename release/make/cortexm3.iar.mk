#/**
# * AS - the open source Automotive Software on https://github.com/parai
# *
# * Copyright (C) 2015  AS <parai@foxmail.com>
# *
# * This source code is free software; you can redistribute it and/or modify it
# * under the terms of the GNU General Public License version 2 as published by the
# * Free Software Foundation; See <http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt>.
# *
# * This program is distributed in the hope that it will be useful, but
# * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# * for more details.
# */
#common compilers
AS  = $(COMPILER_DIR)/arm/bin/iasmarm.exe
CC  = $(COMPILER_DIR)/arm/bin/iccarm.exe
LD  = $(COMPILER_DIR)/arm/bin/ilinkarm.exe
AR  = $(COMPILER_DIR)/arm/bin/iarchive.exe
RM  = rm

ifeq ($(CC), $(wildcard $(CC)))
else
$(error fix your iar compiler path)
endif

#common flags
asflags-y += -s+ -M\<\> -w+ -r --cpu Cortex-M3 --fpu None
cflags-y += --no_cse --no_unroll --no_inline --no_code_motion
cflags-y += --no_tbaa --no_clustering --no_scheduling 
cflags-y += --cpu=Cortex-M3 -e --fpu=None --endian=little
cflags-y += --dlib_config $(COMPILER_DIR)/arm/INC/c/DLib_Config_Normal.h
cflags-y += --diag_suppress=Pa050
ifeq ($(debug),true)
cflags-y += --debug -On
else
cflags-y += --debug -Oh 
endif

ldflags-y += --config $(link-script)
ldflags-y += --semihosting --entry __iar_program_start --vfe

inc-y += -I$(COMPILER_DIR)/arm/CMSIS/Include

dir-y += $(src-dir)

VPATH += $(dir-y)
inc-y += $(foreach x,$(dir-y),$(addprefix -I,$(x)))	
	
obj-y += $(patsubst %.c,$(obj-dir)/%.o,$(foreach x,$(dir-y),$(notdir $(wildcard $(addprefix $(x)/*,.c)))))		
obj-y += $(patsubst %.S,$(obj-dir)/%.o,$(foreach x,$(dir-y),$(notdir $(wildcard $(addprefix $(x)/*,.S)))))		

#common rules	

$(obj-dir)/%.o:%.S
	@echo
	@echo "  >> AS $(notdir $<)"
	@$(AS) $(asflags-y) $(inc-y) $(def-y) -o $@ $<
	
$(obj-dir)/%.o:%.c
	@echo
	@echo "  >> CC $(notdir $<)"
	@gcc -c $(inc-y) $(def-y) -MM -MF $(patsubst %.o,%.d,$@) -MT $@ $<
	@$(CC) $(cflags-y) $(inc-y) $(def-y) -o $@ $<	
	
ifeq ($(host), Linux)
include $(wildcard $(obj-dir)/*.d)
else
-include $(obj-dir)/as.dep
endif
	
.PHONY:all clean

$(obj-dir):
	@mkdir -p $(obj-dir)
	
$(exe-dir):
	@mkdir -p $(exe-dir)	

include $(wildcard $(obj-dir)/*.d)

exe:$(obj-dir) $(exe-dir) $(obj-y)
	@echo "  >> LD $(target-y).exe"
	@$(LD) $(obj-y) $(ldflags-y) -o $(exe-dir)/$(target-y).exe 
	@echo ">>>>>>>>>>>>>>>>>  BUILD $(exe-dir)/$(target-y)  DONE   <<<<<<<<<<<<<<<<<<<<<<"	
	
dll:$(obj-dir) $(exe-dir) $(obj-y)
	@echo "  >> LD $(target-y).DLL"
	@$(CC) -shared $(obj-y) $(ldflags-y) -o $(exe-dir)/$(target-y).dll 
	@echo ">>>>>>>>>>>>>>>>>  BUILD $(exe-dir)/$(target-y)  DONE   <<<<<<<<<<<<<<<<<<<<<<"

lib:$(obj-dir) $(exe-dir) $(obj-y)
	@echo "  >> LD $(target-y).LIB"
	@$(AR) -r $(exe-dir)/lib$(target-y).a $(obj-y)  
	@echo ">>>>>>>>>>>>>>>>>  BUILD $(exe-dir)/$(target-y)  DONE   <<<<<<<<<<<<<<<<<<<<<<"		

clean-obj:
	@rm -fv $(obj-dir)/*
	@rm -fv $(exe-dir)/*
	
clean-obj-src:clean-obj
	@rm -fv $(src-dir)/*

